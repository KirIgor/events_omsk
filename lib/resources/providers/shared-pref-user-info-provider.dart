import 'dart:convert';

import 'package:omsk_events/resources/providers/user-info-provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceUserInfoProvider implements UserInfoProvider {
  static const String USER_INFO = "user_info";

  static UserInfo _userInfo;

  String _padBase64(String base64) {
    switch (base64.length % 4) {
      case 0:
        return base64;
      case 1:
        return base64 + "===";
      case 2:
        return base64 + "==";
      case 3:
        return base64 + "=";
      default: throw Exception("WTF");
    }
  }

  @override
  Future<UserInfo> getUserInfo() async {
    if (_userInfo != null) return _userInfo;
    final prefs = await SharedPreferences.getInstance();
    final storedUserInfo = prefs.getString(USER_INFO);
    final decodedJson =
        storedUserInfo == null ? null : json.decode(storedUserInfo);
    final userInfo =
        decodedJson == null ? null : UserInfo.fromJson(decodedJson);

    if (userInfo == null || userInfo.token == null) return null;

    final expiresIn = DateTime.fromMillisecondsSinceEpoch(json.decode(
            String.fromCharCodes(base64Decode(
                _padBase64(userInfo.token.split(".")[1]))))["exp"] *
        1000);
    if (expiresIn.isBefore(DateTime.now())) return null;

    _userInfo = userInfo;
    return userInfo;
  }

  @override
  Future<void> setUserInfo(UserInfo info) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(USER_INFO, json.encode(info));
    _userInfo = info;
  }
}
