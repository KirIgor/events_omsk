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
    _photos = (parsedJson["photos"] as List).map((json) => Photo.fromJson(json)).toList();
    liked = parsedJson["liked"];
    _likesCount = parsedJson["likesCount"];
    _mainImage = parsedJson["mainImage"];
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
}

enum OrderBy { likesCount, startDateTime }

enum OrderType { ASC, DESC }
