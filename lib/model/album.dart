import 'photo.dart';

class Album {
  int _id;
  String _name;
  List<Photo> _photos;
  String _year;
  String _description;
  String _author;

  Album.fromJson(Map<String, dynamic> parsedJson) {
    _id = parsedJson["id"];
    _name = parsedJson["name"];
    _year = parsedJson["year"];
    _description = parsedJson["description"];
    _author = parsedJson["author"];
    _photos =
        (parsedJson["photos"] as List).map((p) => Photo.fromJson(p)).toList();
  }

  int get id => _id;

  String get name => _name;

  List<Photo> get photos => _photos;

  String get year => _year;

  String get description => _description;

  String get author => _author;
}
