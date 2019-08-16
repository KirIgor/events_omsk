import 'package:flutter/material.dart';

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

  Color getSpecialDateColor() {
    switch(value) {
      case "1":
        return Colors.orange;
      case "2":
        return Colors.deepOrangeAccent;
      case "3":
        return Colors.red;
      default:
        throw Exception("Неправильный цвет");
    }
  }
}

enum SettingsOrderBy { id, key, value }

enum SettingsOrderType { ASC, DESC }