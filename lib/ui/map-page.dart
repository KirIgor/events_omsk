import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:omsk_events/bloc/event-map-bloc.dart';
import 'package:omsk_events/bloc/bloc-widget.dart';
import 'package:omsk_events/model/setting.dart';
import 'package:omsk_events/model/event-short.dart';

import 'dart:async';

const initZoom = 11.0;
const dZoomToChangeMarkers = 1.0;
const gridCountXInView = 5;
const gridCountYInView = 10;
const omskCameraPosition = LatLng(54.972764, 73.3336552);
// there was bug with infinite loop in init state,
// because onMapCreated doesn't guarantee that getVisibleRegion will
// not return ((0,0), (0,0)), so initialVisibleRegion is hardcoded now
final initialVisibleRegion = LatLngBounds(
    southwest: LatLng(54.8381112099642, 73.19882277399302),
    northeast: LatLng(55.10696676234333, 73.46848703920841));

class MapPage extends StatefulWidget {
  MapPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<MapPage> with TickerProviderStateMixin {
  bool _filterPast = true;

  GoogleMapController _mapController;
  Set<Marker> _markers = Set();
  double _zoom = initZoom;

  EventMapBloc _eventBloc;

  LatLngBounds _cityBounds;
  List<EventShort> _events;
  List<Setting> _settings;

  @override
  void initState() {
    super.initState();

    _eventBloc = BlocWidget.of(context);
  }

  Widget _buildMap() {
    return Scaffold(
        body: Stack(alignment: Alignment.bottomCenter, children: <Widget>[
      GoogleMap(
          markers: _markers,
          onMapCreated: (controller) {
            _mapController = controller;
            _updateMarkers(_zoom, _cityBounds, _settings, _events);
          },
          rotateGesturesEnabled: false,
          initialCameraPosition:
              CameraPosition(target: omskCameraPosition, zoom: initZoom))
    ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Карта"),
            actions: <Widget>[
              IconButton(
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
                    _updateMarkers(_zoom, _cityBounds, _settings, _events);
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
                      final LatLngBounds cityBounds = _calcCityBounds(events);

                      _events = events;
                      _settings = settings;
                      _cityBounds = cityBounds;

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

  bool _dateWithoutTimeEquals(DateTime date1, DateTime date2) {
    if (date1 == null) return date2 == null;
    if (date2 == null) return date1 == null;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isWithinSpecialDates(EventShort e, List<Setting> settings) {
    if (e.endDateTime == null) return false;

    final specialDates = settings
        .where((setting) => setting.key.startsWith("SPECIAL_DATE"))
        .toList();

    specialDates.forEach((setting) {
      final specialDate = DateTime.parse(setting.value);
      if (e.startDateTime.isBefore(specialDate) &&
          e.endDateTime.isAfter(specialDate)) return true;
    });

    return false;
  }

  _getIcon(List<Setting> settings, EventShort e) {
    final bigIcon =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta);
    final withinSpecialDatesIcon =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta);
    final futureIcon =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
    final currentIcon =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    final pastIcon =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    final specialDate1Icon =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    final specialDate2Icon =
        BitmapDescriptor.defaultMarkerWithHue(21); //dark orange
    final specialDate3Icon =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

    if (e.isBig) return bigIcon;

    final now = DateTime.now();

    if (e.endDateTime != null) {
      if (_isWithinSpecialDates(e, settings)) return withinSpecialDatesIcon;
      if (e.startDateTime.isBefore(now) && e.endDateTime.isAfter(now)) {
        return currentIcon;
      }
    } else {
      final specialDate1 = DateTime.parse(settings
          .firstWhere((setting) => setting.key == "SPECIAL_DATE_1")
          .value);
      final specialDate2 = DateTime.parse(settings
          .firstWhere((setting) => setting.key == "SPECIAL_DATE_2")
          .value);
      final specialDate3 = DateTime.parse(settings
          .firstWhere((setting) => setting.key == "SPECIAL_DATE_3")
          .value);

      if (_dateWithoutTimeEquals(e.startDateTime, specialDate1))
        return specialDate1Icon;
      else if (_dateWithoutTimeEquals(e.startDateTime, specialDate2))
        return specialDate2Icon;
      else if (_dateWithoutTimeEquals(e.startDateTime, specialDate3))
        return specialDate3Icon;
      if (_dateWithoutTimeEquals(e.startDateTime, now)) return currentIcon;
    }

    if (e.startDateTime.isAfter(now))
      return futureIcon;
    else
      return pastIcon;
  }

  Future<void> _updateMarkers(double zoom, LatLngBounds cityBounds,
      List<Setting> settings, List<EventShort> events) async {
    print(events);
    final GoogleMapController controller = _mapController;
    LatLngBounds visibleRegion = controller == null
        ? initialVisibleRegion
        : await controller.getVisibleRegion();
    if (visibleRegion.southwest.latitude == 0.0 &&
        visibleRegion.southwest.longitude == 0.0 &&
        visibleRegion.northeast.latitude == 0.0 &&
        visibleRegion.northeast.longitude == 0.0)
      visibleRegion = initialVisibleRegion;
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
        .map((e) => Marker(
            markerId: MarkerId(e.id.toString()),
            zIndex: e.isBig ? 101 : 100,
            alpha: _isWithinSpecialDates(e, settings) && !e.isBig ? 0.6 : 1.0,
            infoWindow: InfoWindow(
                title: e.name,
                snippet: e.eventTimeBounds(),
                onTap: () {
                  _onShowDetails(e);
                }),
            position: LatLng(e.latitude, e.longitude),
            icon: _getIcon(settings, e)))
        .toSet();
  }

  LatLngBounds _calcCityBounds(List<EventShort> events) {
    double minX = double.infinity;
    double maxX = 0;
    double minY = double.infinity;
    double maxY = 0;

    events.forEach((e) {
      LatLng pos = LatLng(e.latitude, e.longitude);

      if (pos.latitude < minY) minY = pos.latitude;
      if (pos.latitude > maxY) maxY = pos.latitude;
      if (pos.longitude < minX) minX = pos.longitude;
      if (pos.longitude > maxX) maxX = pos.longitude;
    });

    return LatLngBounds(
        northeast: LatLng(maxY + 0.001, maxX + 0.001),
        southwest: LatLng(minY - 0.001, minX - 0.001));
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
              title: Text("Крупные события"),
            ),
            ListTile(
              leading: Icon(Icons.location_on,
                  color: Color.fromARGB((0.6 * 255).round(), 255, 0, 255)),
              title: Text(
                  "Попадают на ${justDayFormat.format(specialDate1)}, ${justDayFormat.format(specialDate2)} и/или ${specialDateFormat.format(specialDate3)}"),
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
