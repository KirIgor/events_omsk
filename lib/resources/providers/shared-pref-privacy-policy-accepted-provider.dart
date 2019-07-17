import 'package:omsk_events/resources/providers/privacy-policy-accepted-provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencePrivacyPolicyAcceptedProvider implements PrivacyPolicyAcceptedProvider {
  static const String ACCEPTED_KEY = "privacy-policy-accepted";

  static bool _accepted;

  @override
  Future<bool> getPrivacyPolicyAccepted() async {
    if(_accepted != null) return _accepted;
    final prefs = await SharedPreferences.getInstance();
    _accepted = prefs.getString(ACCEPTED_KEY) == "1";
    return _accepted;
  }

  @override
  Future<void> setPrivacyPolicyAccepted(bool accepted) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(ACCEPTED_KEY, accepted ? "1" : null);
    _accepted = accepted;
    return null;
  }
}
