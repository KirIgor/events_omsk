import 'package:omsk_events/di.dart';
import 'package:omsk_events/resources/providers/user-info-provider.dart';
import 'package:omsk_events/resources/providers/login-api-provider.dart';
import 'package:rxdart/rxdart.dart';

import 'bloc-base.dart';

class UserBloc extends BlocBase {
  final _userInfoProvider = DI.userInfoProvider;
  final _loginProvider = LoginAPIProvider();

  final _userInfoSubject = PublishSubject<UserInfo>();

  Observable<UserInfo> get userInfo => _userInfoSubject.stream;

  Future<void> authenticate(String vkAuthToken, int vkId) async {
    String token = await _loginProvider.login(vkAuthToken);

    UserInfo info = UserInfo(vkId, token);

    await _userInfoProvider.setUserInfo(info);

    print("add user info");
    _userInfoSubject.add(info);
  }

  Future<void> logOut() async {
    await _userInfoProvider.setUserInfo(null);

    _userInfoSubject.add(null);
  }

  @override
  void dispose() {
    print("dispose user bloc");
    _userInfoSubject.close();
  }

  @override
  void init() async {
    final info = await _userInfoProvider.getUserInfo();

    _userInfoSubject.add(info);
  }
}
