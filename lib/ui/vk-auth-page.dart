import 'package:flutter/material.dart';
import 'package:flutter_vk_login/flutter_vk_login.dart';
import 'package:flutter_vk_sdk/flutter_vk_sdk.dart' hide VKAccessToken;

import 'package:omsk_events/bloc/bloc-widget.dart';
import 'package:omsk_events/bloc/user-bloc.dart';
import 'package:omsk_events/di.dart';

import 'dart:io';

enum AgreeAction { agree, disagree }

class VkAuthPage extends StatefulWidget {
  VkAuthPage({Key key}) : super(key: key);

  @override
  _VkAuthPageState createState() => _VkAuthPageState();
}

class _VkAuthPageState extends State<VkAuthPage> {
  UserBloc _bloc;
  static final FlutterVkLogin vkSignIn = new FlutterVkLogin();
  String _error;

  @override
  void initState() {
    super.initState();

    _bloc = BlocWidget.of(context);

    DI.acceptedProvider.getPrivacyPolicyAccepted().then((accepted) {
      if (accepted) {
        vkAuth();
      } else {
        showDialog<AgreeAction>(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(
                    "Для участия в обсуждениях мероприятий приложения «Омск: город сегодня» "
                    "необходимо пройти авторизацию через учетную запись социальной сети "
                    "«ВКонтакте» и подтвердить согласие на передачу общедоступной информации. "
                    "Авторизация также позволит добавлять события в избранное."),
                actions: <Widget>[
                  FlatButton(
                    child: Text('НЕ СОГЛАСЕН'),
                    onPressed: () {
                      Navigator.pop(context, AgreeAction.disagree);
                    },
                  ),
                  FlatButton(
                    child: Text('СОГЛАСЕН'),
                    onPressed: () {
                      Navigator.pop(context, AgreeAction.agree);
                    },
                  ),
                ],
              );
            }).then((agree) async {
          if (agree == AgreeAction.agree) {
            await DI.acceptedProvider.setPrivacyPolicyAccepted(true);
            vkAuth();
          } else
            Navigator.pop(context);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child:
                _error == null ? CircularProgressIndicator() : Text(_error)));
  }

  void vkAuth() async {
    if (Platform.isAndroid) {
      vkSignIn.logIn(['offline']).then((VkLoginResult result) {
        switch (result.status) {
          case VKLoginStatus.loggedIn:
            final VKAccessToken accessToken = result.token;
            _bloc
                .authenticate(accessToken.token, int.parse(accessToken.userId))
                .then((res) {
              Navigator.pop(context);
            });
            break;
          case VKLoginStatus.cancelledByUser:
            setState(() {
              _error = "Аутентификация отменена пользователем.";
            });
            break;
          case VKLoginStatus.error:
            setState(() {
              _error = "Что-то пошло не так: ${result.errorMessage}";
            });
            break;
        }
      });
    } else if (Platform.isIOS) {
      final vkSdk = DI.vkSdkProvider.getInstance();
      final List<String> scopes = [VKPermission.OFFLINE];

      vkSdk.accessAuthorizationFinished.listen((result) async {
        if (result.state == VKAuthorizationState.Error) {
          setState(() {
            _error = "Что-то пошло не так :(";
          });
        }
      });

      vkSdk.authorizationStateUpdated.listen((result) async {
        if (result.state == VKAuthorizationState.Authorized) {
          await _bloc.authenticate(
              result.token.accessToken, int.parse(result.token.userId));
          Navigator.pop(context);
        }
      });

      final isLoggedIn = await vkSdk.isLoggedIn();

      if(isLoggedIn) {
        final accessToken = await vkSdk.accessToken();
        await _bloc.authenticate(
            accessToken.accessToken, int.parse(accessToken.userId));
        print("pop");
        Navigator.pop(context);
      } else {
        try {
          vkSdk.authorize(scopes, isSafariDisabled: true);
        } on VKSdkException catch (error) {
          setState(() {
            _error = "Что-то пошло не так :(";
          });
        }
      }
    }
  }
}
