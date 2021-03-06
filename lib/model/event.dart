import 'package:omsk_events/model/photo.dart';
import 'package:omsk_events/model/event-short.dart';
import 'package:omsk_events/model/setting.dart';

import '../di.dart';

class EventFull {
  int _id;
  String _name;
  String _description;
  bool _hasAlbums;
  DateTime _startDateTime;
  DateTime _endDateTime;
  double _latitude;
  double _longitude;
  String _phone;
  String _address;
  String _place;
  String _externalRef;
  List<Photo> _photos;
  bool liked;
  int _likesCount;
  String _mainImage;
  bool _isBig;
  bool _isFree;

  EventFull(DateTime startDateTime, DateTime endDateTime)
      : _startDateTime = startDateTime,
        _endDateTime = endDateTime;

  EventFull.fromJson(Map<String, dynamic> parsedJson) {
    _id = parsedJson["id"];
    _name = parsedJson["name"];
    _description =
        parsedJson["description"] ?? parsedJson["croppedDescription"];
    _hasAlbums = parsedJson["hasAlbums"];
    _startDateTime =
        DI.dateConverter.convert(DateTime.parse(parsedJson["startDateTime"]));
    _endDateTime = parsedJson["endDateTime"] != null
        ? DI.dateConverter.convert(DateTime.parse(parsedJson["endDateTime"]))
        : null;
    _latitude = parsedJson["latitude"];
    _longitude = parsedJson["longitude"];
    _phone = parsedJson["phone"];
    _address = parsedJson["address"];
    _place = parsedJson["place"];
    _externalRef = parsedJson["externalRef"];
    _photos = (parsedJson["photos"] as List)
        .map((json) => Photo.fromJson(json))
        .toList();
    liked = parsedJson["liked"];
    _likesCount = parsedJson["likesCount"];
    _mainImage = parsedJson["mainImage"];
    _isBig = parsedJson["isBig"];
    _isFree = parsedJson["isFree"];
  }

  String eventTimeBounds() => EventShort.fromEventFull(this).eventTimeBounds();

  bool isMultidayAndWithinSpecialDates(List<Setting> settings) =>
      EventShort.fromEventFull(this).isMultidayAndWithinSpecialDates(settings);

  EventType getEventType(List<Setting> settings) =>
      EventShort.fromEventFull(this).getEventType(settings);

  bool isToday() => EventShort.fromEventFull(this).isToday();
  bool isOnGoing() => EventShort.fromEventFull(this).isOnGoing();

  int get id => _id;
  String get name => _name;
  String get description => _description;
  bool get hasAlbums => _hasAlbums;
  DateTime get startDateTime => _startDateTime;
  DateTime get endDateTime => _endDateTime;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String get phone => _phone;
  String get address => _address;
  String get place => _place;
  String get externalRef => _externalRef;
  List<Photo> get photos => _photos;
  int get likesCount => _likesCount;
  String get mainPhoto => _mainImage;

  bool get isBig => _isBig;
  bool get isFree => _isFree;
}

enum EventOrderBy { likesCount, startDateTime }

enum EventOrderType { ASC, DESC }
