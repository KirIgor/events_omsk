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
  List<String> _photos;
  bool liked;
  int _likesCount;

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
    _photos = List<String>.from(parsedJson["photos"]);
    liked = parsedJson["liked"];
    _likesCount = parsedJson["likesCount"];
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
  List<String> get photos => _photos;
  int get likesCount => _likesCount;

  String get mainPhoto => photos.isNotEmpty ? photos.first : null;
}

enum OrderBy { LIKES_COUNT, START_DATE_TIME }

enum OrderType { ASC, DESC }
