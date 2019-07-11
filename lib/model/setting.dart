class Setting {
  int _id;
  String _key;
  String _value;

  Setting.fromJson(Map<String, dynamic> parsedJson) {
    _id = parsedJson["id"];
    _key = parsedJson["key"];
    _value = parsedJson["value"];
  }

  int get id => _id;
  String get key => _key;
  String get value => _value;
}

enum OrderBy { id, key, value }

enum OrderType { ASC, DESC }