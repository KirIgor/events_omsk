import 'package:flutter/material.dart';
import 'package:flutter_vk_login/flutter_vk_login.dart';
import 'package:flutter_vk_sdk/flutter_vk_sdk.dart' hide VKAccessToken;

import 'package:omsk_events/bloc/bloc-widget.dart';
import 'package:omsk_events/bloc/user-bloc.dart';
import 'package:omsk_events/di.dart';

import 'dart:io';

class VkAuthPage extends StatefulWidget {
  VkAuthPage({Key key}) : super(key: key);

  @override
  _VkAuthPageState createState() => _VkAuthPageState();
}

class _VkAuthPageState extends State<VkAuthPage> {
  static final FlutterVkLogin vkSignIn = new FlutterVkLogin();
  String _error;

  @override
  void initState() {
    super.initState();

    UserBloc bloc = BlocWidget.of(context);

    if (Platform.isAndroid) {
      vkSignIn.logIn(['offline']).then((VkLoginResult result) {
        switch (result.status) {
          case VKLoginStatus.loggedIn:
            final VKAccessToken accessToken = result.token;
            bloc
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

      vkSdk.authorizationStateUpdated.listen((result) async {
        if (result.state == VKAuthorizationState.Authorized) {
          await bloc.authenticate(
              result.token.accessToken, int.parse(result.token.userId));
          Navigator.pop(context);
        } else {
          setState(() {
            _error = "Что-то пошло не так: ${result.error}";
          });
        }
      });

      vkSdk.authorize(scopes, isSafariDisabled: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child:
                _error == null ? CircularProgressIndicator() : Text(_error)));
  }
}
