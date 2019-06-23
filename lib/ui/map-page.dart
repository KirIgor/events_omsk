import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:omsk_events/bloc/event-map-bloc.dart';
import 'package:omsk_events/di.dart';
import 'package:omsk_events/model/event-short.dart';

import 'dart:async';

const initZoom = 11.0;
const dZoomToChangeMarkers = 1.0;
const gridCountXInView = 5;
const gridCountYInView = 10;
const omskCameraPosition = LatLng(54.972764, 73.3336552);

class MapPage extends StatefulWidget {
  MapPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<MapPage> with TickerProviderStateMixin {
  List<EventShort> _events = List();

  EventShort _prev = EventShort(id: -1, startDateTime: DateTime.now());
  EventShort _selected = EventShort(id: -1, startDateTime: DateTime.now());

  AnimationController _controller;
  Animation<Offset> _animationOut;
  Animation<Offset> _animationIn;

  Completer<GoogleMapController> _mapController = Completer();
  Set<Marker> _markers = Set();
  double _prevZoom = initZoom;

  LatLngBounds _cityBounds;
  final _eventBloc = EventMapBloc(repository: DI.eventRepository);

  @override
  void initState() {
    super.initState();

    _eventBloc.fetchAllEvents();
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

    _mapController.future.then((controller) async {
      final markers = _getAllMarkersFromEvents(_events);
      _cityBounds = _calcCityBounds(markers);
      final visibleRegion = await controller.getVisibleRegion();

      setState(() {
        _markers = _filterMarkers(markers, visibleRegion, initZoom);
      });
    });
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
            title: Text(e.name ?? ""),
            subtitle: Text(
                DateFormat("d MMMM y H:mm", "ru_RU").format(e.startDateTime)),
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
          _mapController.complete(controller);
        },
        rotateGesturesEnabled: false,
        initialCameraPosition:
            CameraPosition(target: omskCameraPosition, zoom: initZoom),
        onCameraMove: (pos) async {
          if ((pos.zoom - _prevZoom).abs() < dZoomToChangeMarkers ||
              pos.zoom > 14 && _prevZoom > 14) return;

          final GoogleMapController controller = await _mapController.future;
          final visibleRegion = await controller.getVisibleRegion();
          final markers = _getAllMarkersFromEvents(_events);

          setState(() {
            _prevZoom = pos.zoom;
            _markers = _filterMarkers(markers, visibleRegion, pos.zoom);
          });
        },
      ),
      Opacity(
          opacity: _prev.id == -1 ? 0 : 1,
          child: _buildEventTile(_prev, _animationOut)),
      _buildEventTile(_selected, _animationIn)
    ]));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _eventBloc.allEvents,
      builder: (context, AsyncSnapshot<List<EventShort>> snapshot) {
        if (snapshot.hasData) {
          _events = snapshot.data;

          return _buildMap();
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Set<Marker> _getAllMarkersFromEvents(List<EventShort> events) {
    return events
        .map((e) => Marker(
            markerId: MarkerId(e.id.toString()),
            onTap: () {
              setState(() {
                _prev = _selected;
                _selected = e;

                _markers = _markers
                    .map((m) => Marker(
                        markerId: m.markerId,
                        position: m.position,
                        onTap: m.onTap,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            int.parse(m.markerId.value) == _selected.id
                                ? BitmapDescriptor.hueBlue
                                : BitmapDescriptor.hueAzure)))
                    .toSet();
              });
              _controller.reset();
              _controller.forward();
            },
            position: LatLng(e.latitude, e.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(e.id == _selected.id
                ? BitmapDescriptor.hueBlue
                : BitmapDescriptor.hueAzure)))
        .toSet();
  }

  LatLngBounds _calcCityBounds(Set<Marker> markers) {
    double minX = double.infinity;
    double maxX = 0;
    double minY = double.infinity;
    double maxY = 0;

    markers.forEach((m) {
      LatLng pos = m.position;

      if (pos.latitude < minY) minY = pos.latitude;
      if (pos.latitude > maxY) maxY = pos.latitude;
      if (pos.longitude < minX) minX = pos.longitude;
      if (pos.longitude > maxX) maxX = pos.longitude;
    });

    return LatLngBounds(
        northeast: LatLng(maxY + 1, maxX + 1),
        southwest: LatLng(minY - 1, minX - 1));
  }

  double _distanceSquared(LatLng p1, LatLng p2) {
    final dy = p2.latitude - p1.latitude;
    final dx = p2.longitude - p1.longitude;
    return dx * dx + dy * dy;
  }

  Set<Marker> _filterMarkers(
      Set<Marker> markers, LatLngBounds bounds, double zoom) {
    if (zoom > 13) return markers;

    Set<Marker> res = Set();

    final minY = bounds.southwest.latitude;
    final maxY = bounds.northeast.latitude;
    final minX = bounds.southwest.longitude;
    final maxX = bounds.northeast.longitude;

    final cityMinY = _cityBounds.southwest.latitude;
    final cityMaxY = _cityBounds.northeast.latitude;
    final cityMinX = _cityBounds.southwest.longitude;
    final cityMaxX = _cityBounds.northeast.longitude;

    final gridElWidth = (maxX - minX) / gridCountXInView;
    final gridElHeight = (maxY - minY) / gridCountYInView;

    final gridCountX = (cityMaxX - cityMinX) / gridElWidth;
    final gridCountY = (cityMaxY - cityMinY) / gridElHeight;

    for (int i = 0; i < gridCountX; ++i) {
      for (int j = 0; j < gridCountY; ++j) {
        final gridElBounds = LatLngBounds(
            northeast: LatLng(
              cityMinY + (j + 1) * gridElHeight,
              cityMinX + (i + 1) * gridElWidth,
            ),
            southwest: LatLng(
                cityMinY + j * gridElHeight, cityMinX + i * gridElWidth));
        final gridElCenter = LatLng(
            gridElBounds.southwest.latitude +
                (gridElBounds.northeast.latitude -
                        gridElBounds.southwest.latitude) /
                    2,
            gridElBounds.southwest.longitude +
                (gridElBounds.northeast.longitude -
                        gridElBounds.southwest.longitude) /
                    2);

        final chosen = markers
            .where((m) => gridElBounds.contains(m.position))
            .toList()
              ..sort((m1, m2) => (_distanceSquared(m2.position, gridElCenter) -
                      _distanceSquared(m1.position, gridElCenter))
                  .round());

        if (chosen.length != 0) res.add(chosen.first);
      }
    }

    return res;
  }

  void _onShowDetails(EventShort e) {
    Navigator.of(context).pushNamed("/event_details", arguments: e.id);
  }
}
