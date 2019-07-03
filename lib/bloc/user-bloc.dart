import 'package:omsk_events/resources/providers/shared-pref-token-provider.dart';
import 'package:omsk_events/resources/providers/shared-pref-user-info-provider.dart';
import 'package:omsk_events/resources/providers/user-info-provider.dart';
import 'package:omsk_events/resources/providers/login-api-provider.dart';
import 'package:rxdart/rxdart.dart';

import 'bloc-base.dart';

class UserBloc extends BlocBase {
  final _tokenProvider = SharedPreferenceTokenProvider();
  final _userInfoProvider = SharedPreferenceUserInfoProvider();
  final  _loginProvider = LoginAPIProvider();

  final _userInfoSubject = PublishSubject<UserInfo>();

  Observable<UserInfo> get userInfo => _userInfoSubject.stream;

  Future<void> authenticate(String vkAuthToken, int vkId) async {
    UserInfo info = UserInfo(vkId);

    String token = await _loginProvider.login(vkAuthToken);

    await _tokenProvider.setToken(token);
    await _userInfoProvider.setUserInfo(info);

    _userInfoSubject.sink.add(info);
  }

  Future<void> logOut() async {
    await _tokenProvider.setToken(null);
    await _userInfoProvider.setUserInfo(null);

    _userInfoSubject.sink.add(null);
  }

  @override
  void dispose() {
    _userInfoSubject.close();
  }

  @override
  void init() async {
    final info = await _userInfoProvider.getUserInfo();

    _userInfoSubject.sink.add(info);
  }
}
