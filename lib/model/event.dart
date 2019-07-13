import 'package:intl/intl.dart';

import 'package:omsk_events/model/photo.dart';

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
  String _externalRef;
  List<Photo> _photos;
  bool liked;
  int _likesCount;
  String _mainImage;
  bool _isBig;

  EventFull(DateTime startDateTime, DateTime endDateTime)
      : _startDateTime = startDateTime,
        _endDateTime = endDateTime;

  EventFull.fromJson(Map<String, dynamic> parsedJson) {
    _id = parsedJson["id"];
    _name = parsedJson["name"];
    _description =
        parsedJson["description"] ?? parsedJson["croppedDescription"];
    _hasAlbums = parsedJson["hasAlbums"];
    _startDateTime = DateTime.parse(parsedJson["startDateTime"]).toLocal();
    _endDateTime = parsedJson["endDateTime"] != null
        ? DateTime.parse(parsedJson["endDateTime"]).toLocal()
        : null;
    _latitude = parsedJson["latitude"];
    _longitude = parsedJson["longitude"];
    _phone = parsedJson["phone"];
    _address = parsedJson["address"];
    _externalRef = parsedJson["externalRef"];
    _photos = (parsedJson["photos"] as List)
        .map((json) => Photo.fromJson(json))
        .toList();
    liked = parsedJson["liked"];
    _likesCount = parsedJson["likesCount"];
    _mainImage = parsedJson["mainImage"];
    _isBig = parsedJson["isBig"];
  }

  String eventTimeBounds() {
    if (this.endDateTime == null)
      return "${DateFormat("d MMMM H:mm", "ru_RU").format(this.startDateTime)}";

    if (this.startDateTime.year == this.endDateTime.year &&
        this.startDateTime.month == this.endDateTime.month &&
        this.startDateTime.day == this.endDateTime.day) {
      return "${DateFormat("d MMMM H:mm", "ru_RU").format(this.startDateTime)} "
          "${DateFormat("Hm", "ru_RU").format(this.endDateTime)}";
    } else {
      return "${DateFormat("d MMMM H:mm", "ru_RU").format(this.startDateTime)} "
          "- ${DateFormat("d MMMM H:mm", "ru_RU").format(this.endDateTime)}";
    }
  }

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
  String get externalRef => _externalRef;
  List<Photo> get photos => _photos;
  int get likesCount => _likesCount;
  String get mainPhoto => _mainImage;

  bool get isBig => _isBig;

  bool isOnGoing() {
    if (endDateTime == null) return false;

    final currentMillis = DateTime.now().millisecondsSinceEpoch;
    return (startDateTime.millisecondsSinceEpoch <= currentMillis &&
        currentMillis <= endDateTime.millisecondsSinceEpoch);
  }
}

enum OrderBy { likesCount, startDateTime }

enum OrderType { ASC, DESC }
