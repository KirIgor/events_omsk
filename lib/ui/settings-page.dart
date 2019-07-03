import 'package:flutter/material.dart';

import 'package:omsk_events/bloc/user-bloc.dart';
import 'package:omsk_events/bloc/bloc-widget.dart';

class Setting {
  final String title;
  final String description;
  const Setting({this.title, this.description});
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserBloc bloc = BlocWidget.of(context);

    return StreamBuilder(
        stream: bloc.userInfo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            List<Setting> settings = <Setting>[];
            if (snapshot.data == null)
              settings.add(Setting(title: 'Вход через VK', description: '.'));
            else
              settings.add(Setting(title: 'Выйти из VK', description: '.'));
            settings.add(Setting(title: 'О приложении', description: ' '));

            return Scaffold(
              body: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  var setting = settings[index];

                  return ListTile(
                    title: Text(setting.title),
                    onTap: () => onTapped(setting, context),
                  );
                },
                itemCount: settings.length,
              ),
            ); //Scaffold
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}

void onTapped(Setting setting, BuildContext context) {
  UserBloc bloc = BlocWidget.of(context);

  if (setting.title == 'О приложении') {
    Navigator.pushNamed(context, "/about");
  } else if (setting.title == 'Вход через VK') {
    Navigator.pushNamed(context, "/auth");
  } else if (setting.title == 'Выйти из VK') {
    bloc.logOut();
  }
  // else return null;
}
