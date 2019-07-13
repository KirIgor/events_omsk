import 'package:omsk_events/resources/providers/token-provider.dart';
import 'package:omsk_events/resources/providers/user-info-provider.dart';
import 'package:omsk_events/di.dart';

class UserInfoTokenProvider implements TokenProvider {
  final _userInfoProvider = DI.userInfoProvider;

  @override
  Future<String> getToken() async {
    final userInfo = await _userInfoProvider.getUserInfo();
    return userInfo?.token;
  }

  @override
  Future<void> setToken(String token) async {
    final userInfo = await _userInfoProvider.getUserInfo();
    await _userInfoProvider.setUserInfo(UserInfo(userInfo.vkId, token));
  }
}
