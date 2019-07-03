class Comment {
  int _id;
  String _userAvatar;
  String _userName;
  int _vkId;
  String _text;
  DateTime _modifiedAt;
  bool justCreated = false;

  Comment.fromJson(Map<String, dynamic> parsedJson) {
    _id = parsedJson["id"];
    _text = parsedJson["text"];
    _userAvatar = parsedJson["userAvatar"];
    _userName = parsedJson["userName"];
    _vkId = parsedJson["vkId"];
    _modifiedAt = DateTime.parse(parsedJson["modifiedAt"]).toLocal();
  }

  Comment({int id, String text, String userAvatar, String userName})
      : _id = id,
        _text = text,
        _userAvatar = userAvatar,
        _userName = userName;

  int get id => _id;
  String get text => _text;
  String get userAvatar => _userAvatar;
  String get userName => _userName;
  int get vkId => _vkId;
  DateTime get modifiedAt => _modifiedAt;
}
