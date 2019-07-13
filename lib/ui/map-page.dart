import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:omsk_events/bloc/event-map-bloc.dart';
import 'package:omsk_events/bloc/bloc-widget.dart';
import 'package:omsk_events/model/setting.dart';
import 'package:omsk_events/model/event-short.dart';

import 'dart:async';

const initZoom = 11.5;
const dZoomToChangeMarkers = 1.0;
const gridCountXInView = 5;
const gridCountYInView = 10;
const omskCameraPosition = LatLng(54.982764, 73.3536552);

enum MarkerType {
  MULTIDAY_WITHIN_SPECIAL_DATES,
  SPECIAL_DATE_1,
  SPECIAL_DATE_2,
  SPECIAL_DATE_3,
  CURRENT,
  FUTURE,
  PAST
}

class MapPage extends StatefulWidget {
  MapPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<MapPage> with TickerProviderStateMixin {
  bool _filterPast = true;

  Set<Marker> _markers = Set();
  double _zoom = initZoom;

  EventMapBloc _eventBloc;

  List<EventShort> _events;
  List<Setting> _settings;

  EventShort _prev = EventShort(id: -1, startDateTime: DateTime.now());
  EventShort _selected = EventShort(id: -1, startDateTime: DateTime.now());

  AnimationController _controller;
  Animation<Offset> _animationOut;
  Animation<Offset> _animationIn;

  @override
  void initState() {
    super.initState();

    _eventBloc = BlocWidget.of(context);
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _animationOut = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 1.0))
        .animate(CurvedAnimation(
            parent: _controller,
            curve: const Interval(
              0.0,
              0.5,
              curve: Curves.easeOut,
            )));
    _animationIn =
        Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _controller,
                curve: const Interval(
                  0.5,
                  1,
                  curve: Curves.easeIn,
                )));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildEventTile(EventShort e, Animation a) {
    return SlideTransition(
      position: a,
      child: Container(
          color: Colors.white,
          child: ListTile(
            enabled: true,
            onTap: () => _onShowDetails(e),
            leading: Icon(Icons.description),
            title: Text(
              e.name ?? "",
              style: TextStyle(
                  fontWeight: e.isBig != null && e.isBig
                      ? FontWeight.bold
                      : FontWeight.normal),
            ),
            subtitle: Text(e.eventTimeBounds()),
            trailing: Icon(Icons.navigate_next),
          )),
    );
  }

  Widget _buildMap() {
    return Scaffold(
        body: Stack(alignment: Alignment.bottomCenter, children: <Widget>[
      GoogleMap(
          markers: _markers,
          onMapCreated: (controller) {
            _updateMarkers(_zoom, _settings, _events);
          },
          rotateGesturesEnabled: false,
          initialCameraPosition:
              CameraPosition(target: omskCameraPosition, zoom: initZoom)),
      Opacity(
          opacity: _prev.id == -1 ? 0 : 1,
          child: _buildEventTile(_prev, _animationOut)),
      _buildEventTile(_selected, _animationIn)
    ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Карта"),
            actions: <Widget>[
              IconButton(
                tooltip: "Цветовое кодирование",
                icon: Icon(Icons.not_listed_location),
                onPressed: () {
                  _showHelp(_settings);
                },
              ),
              PopupMenuButton(
                tooltip: "Фильтрация",
                icon: Icon(Icons.filter_list),
                itemBuilder: (context) => [
                  CheckedPopupMenuItem(
                    child: Text("Убрать прошедшие"),
                    value: "removePast",
                    checked: _filterPast,
                  )
                ],
                onSelected: (value) async {
                  if (value == "removePast") {
                    _filterPast = !_filterPast;
                    _updateMarkers(_zoom, _settings, _events);
                  }
                },
              )
            ],
            backgroundColor: Colors.white),
        body: StreamBuilder(
            stream: _eventBloc.allSettings,
            builder: (context, settingsSnapshot) => StreamBuilder(
                  stream: _eventBloc.allEvents,
                  builder: (context,
                      AsyncSnapshot<List<EventShort>> eventsSnapshot) {
                    if (settingsSnapshot.connectionState ==
                            ConnectionState.active &&
                        eventsSnapshot.connectionState ==
                            ConnectionState.active) {
                      final events = eventsSnapshot.data;
                      final settings = settingsSnapshot.data;

                      _events = events;
                      _settings = settings;

                      return _buildMap();
                    } else if (eventsSnapshot.hasError ||
                        settingsSnapshot.hasError) {
                      return Text(eventsSnapshot.hasError
                          ? eventsSnapshot.error.toString()
                          : settingsSnapshot.error);
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                )));
  }

  DateTime _dateWithoutTime(DateTime dateTime) => dateTime == null
      ? null
      : DateTime(dateTime.year, dateTime.month, dateTime.day);

  bool _isMultidayAndWithinSpecialDates(EventShort e, List<Setting> settings) {
    if (e.endDateTime == null) return false;

    final startDate = _dateWithoutTime(e.startDateTime);
    final endDate = _dateWithoutTime(e.endDateTime);

    if (startDate == endDate) return false;

    final specialDates = settings
        .where((setting) => setting.key.startsWith("SPECIAL_DATE"))
        .toList();

    return specialDates.any((setting) {
      final specialDate = _dateWithoutTime(DateTime.parse(setting.value));
      return (startDate.millisecondsSinceEpoch <=
              specialDate.millisecondsSinceEpoch &&
          endDate.millisecondsSinceEpoch >= specialDate.millisecondsSinceEpoch);
    });
  }

  double _getZIndex(MarkerType type, EventShort e) {
    double res =
        (MarkerType.values.length - MarkerType.values.indexOf(type)).toDouble();
    if (e.isBig && type != MarkerType.PAST) res += MarkerType.values.length;
    return res;
  }

  MarkerType _getMarkerType(List<Setting> settings, EventShort e) {
    final now = DateTime.now();

    final startDate = _dateWithoutTime(e.startDateTime);
    final endDate = _dateWithoutTime(e.endDateTime);

    final specialDate1 = _dateWithoutTime(DateTime.parse(settings
        .firstWhere((setting) => setting.key == "SPECIAL_DATE_1")
        .value));
    final specialDate2 = _dateWithoutTime(DateTime.parse(settings
        .firstWhere((setting) => setting.key == "SPECIAL_DATE_2")
        .value));
    final specialDate3 = _dateWithoutTime(DateTime.parse(settings
        .firstWhere((setting) => setting.key == "SPECIAL_DATE_3")
        .value));

    if (e.endDateTime != null) {
      if (e.endDateTime.isBefore(now)) return MarkerType.PAST;
      if (_isMultidayAndWithinSpecialDates(e, settings))
        return MarkerType.MULTIDAY_WITHIN_SPECIAL_DATES;
      if (startDate == endDate) {
        if (startDate == specialDate1)
          return MarkerType.SPECIAL_DATE_1;
        else if (startDate == specialDate2)
          return MarkerType.SPECIAL_DATE_2;
        else if (startDate == specialDate3) return MarkerType.SPECIAL_DATE_3;
      }
      if (e.startDateTime.isBefore(now) && e.endDateTime.isAfter(now)) {
        return MarkerType.CURRENT;
      }
    } else {
      if (e.startDateTime.isBefore(now)) return MarkerType.PAST;

      if (startDate == specialDate1)
        return MarkerType.SPECIAL_DATE_1;
      else if (startDate == specialDate2)
        return MarkerType.SPECIAL_DATE_2;
      else if (startDate == specialDate3) return MarkerType.SPECIAL_DATE_3;
      if (startDate == _dateWithoutTime(now)) return MarkerType.CURRENT;
    }
    return MarkerType.FUTURE;
  }

  _getIcon(MarkerType markerType) {
    switch (markerType) {
      case MarkerType.MULTIDAY_WITHIN_SPECIAL_DATES:
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueMagenta);
      case MarkerType.SPECIAL_DATE_1:
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange);
      case MarkerType.SPECIAL_DATE_2:
        return BitmapDescriptor.defaultMarkerWithHue(21); //dark orange
      case MarkerType.SPECIAL_DATE_3:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case MarkerType.CURRENT:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case MarkerType.FUTURE:
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueYellow);
      case MarkerType.PAST:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }
  }

  Future<void> _updateMarkers(
      double zoom, List<Setting> settings, List<EventShort> events) async {
    final markers = _getAllMarkersFromEvents(settings, events);

    setState(() {
      _markers = markers;
    });
  }

  Set<Marker> _getAllMarkersFromEvents(
      List<Setting> settings, List<EventShort> events) {
    final now = DateTime.now();
    return events
        .where((e) => _filterPast
            ? e.endDateTime != null
                ? e.endDateTime.isAfter(now)
                : e.startDateTime.isAfter(now)
            : true)
        .map((e) {
      final markerType = _getMarkerType(settings, e);
      return Marker(
          markerId: MarkerId(e.id.toString()),
          zIndex: _getZIndex(markerType, e),
          onTap: () {
            setState(() {
              _prev = _selected;
              _selected = e;
            });
            _controller.reset();
            _controller.forward();
          },
          position: LatLng(e.latitude, e.longitude),
          icon: _getIcon(markerType));
    }).toSet();
  }

  void _showHelp(List<Setting> settings) {
    final specialDate1 = DateTime.parse(settings
        .firstWhere((setting) => setting.key == "SPECIAL_DATE_1")
        .value);
    final specialDate2 = DateTime.parse(settings
        .firstWhere((setting) => setting.key == "SPECIAL_DATE_2")
        .value);
    final specialDate3 = DateTime.parse(settings
        .firstWhere((setting) => setting.key == "SPECIAL_DATE_3")
        .value);

    final justDayFormat = DateFormat("d");
    final specialDateFormat = DateFormat("d MMMM", "ru_RU");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text("Цветовое кодирование"),
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.location_on,
                  color: Color.fromARGB(255, 255, 0, 255)),
              title: Text(
                  "Длящиеся несколько дней и выпадающие на ${justDayFormat.format(specialDate1)}, ${justDayFormat.format(specialDate2)} и/или ${specialDateFormat.format(specialDate3)}"),
            ),
            ListTile(
              leading: Icon(Icons.location_on, color: Colors.orange),
              title: Text(specialDateFormat.format(specialDate1)),
            ),
            ListTile(
              leading: Icon(Icons.location_on,
                  color: Color.fromARGB(255, 255, 117, 24)),
              title: Text(specialDateFormat.format(specialDate2)),
            ),
            ListTile(
              leading: Icon(Icons.location_on, color: Colors.red),
              title: Text(specialDateFormat.format(specialDate3)),
            ),
            ListTile(
              leading: Icon(Icons.location_on, color: Colors.green),
              title: Text("Сегодня"),
            ),
            ListTile(
              leading: Icon(Icons.location_on,
                  color: Color.fromARGB(255, 0, 127, 255)),
              title: Text("Прошедшие"),
            ),
            ListTile(
              leading: Icon(Icons.location_on, color: Colors.yellow),
              title: Text("В другие дни"),
            ),
          ],
        );
      },
    );
  }

  void _onShowDetails(EventShort e) {
    Navigator.of(context).pushNamed("/event_details", arguments: e.id);
  }
}
