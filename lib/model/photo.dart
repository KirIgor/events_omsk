class Photo {
  int _id;
  String _src;
  String _description;

  Photo.fromJson(Map<String, dynamic> parsedJson) {
    _id = parsedJson["id"];
    _src = parsedJson["src"];
    _description = parsedJson["description"];
  }

  int get id => _id;
  String get src => _src;
  String get description => _description;
}
