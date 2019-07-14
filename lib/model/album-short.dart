
class AlbumShort {
  int _id;
  String _name;
  String _cover;
  String _year;

  AlbumShort.fromJson(Map<String, dynamic> parsedJson) {
    _id = parsedJson["id"];
    _name = parsedJson["name"];
    _cover = parsedJson["cover"];
    _year = parsedJson["year"];
  }

  int get id => _id;
  String get name => _name;
  String get cover => _cover;
  String get year => _year;
}
