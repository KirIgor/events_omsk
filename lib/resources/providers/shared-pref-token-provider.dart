import 'package:omsk_events/resources/providers/token-provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceTokenProvider implements TokenProvider {
  static const String TOKEN_KEY = "token";

  // static const testToken = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiI1MzU5NDgxMDYiLCJleHAiOjE1NjM2MjE1MTV9.VRkeZ4dcG4OyqICtd1C6cMWa9JNCozabuUzyFoDmHRGNykbs7_4oq2DhziZU5bWXEfuoRX2KJ7if7jY6O-1Jaw";
  static String _token;

  @override
  Future<String> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(TOKEN_KEY);
    _token = token;
    return token;
  }

  @override
  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(TOKEN_KEY, token);
    _token = token;
  }
}
