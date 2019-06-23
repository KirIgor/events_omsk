import 'photo.dart';

class Album {
  int _id;
  String _name;
  List<Photo> _photos;

  Album.fromJson(Map<String, dynamic> parsedJson) {
    _id = parsedJson["id"];
    _name = parsedJson["name"];
    _photos =
        (parsedJson["photos"] as List).map((p) => Photo.fromJson(p)).toList();
  }

  int get id => _id;
  String get name => _name;
  List<Photo> get photos => _photos;
}
