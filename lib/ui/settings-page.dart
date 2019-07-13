import 'package:flutter/material.dart';

import 'package:omsk_events/bloc/user-bloc.dart';
import 'package:omsk_events/bloc/bloc-widget.dart';

class Setting {
  final String title;
  final String description;
  final Icon icon;

  const Setting({this.title, this.description, this.icon});
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserBloc bloc = BlocWidget.of(context);

    return Scaffold(
        appBar: AppBar(title: Text("Настройки"), backgroundColor: Colors.white),
        body: StreamBuilder(
            stream: bloc.userInfo,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                List<Setting> settings = <Setting>[];
                if (snapshot.data == null)
                  settings
                      .add(Setting(title: "Вход через VK", description: ".", icon: Icon(Icons.vpn_key)));
                else
                  settings.add(Setting(title: "Выйти из VK", description: ".", icon: Icon(Icons.vpn_key)));
                settings.add(Setting(title: "О приложении", description: " ", icon: Icon(Icons.info_outline)));
                settings.add(Setting(title: "О нас", description:  " ", icon: Icon(Icons.people)));

                return Scaffold(
                  body: ListView.separated(
                    separatorBuilder: (context, index) => Divider(),
                    itemBuilder: (BuildContext context, int index) {
                      var setting = settings[index];

                      return ListTile(
                        leading: setting.icon,
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
            }));
  }
}

void onTapped(Setting setting, BuildContext context) {
  UserBloc bloc = BlocWidget.of(context);

  switch(setting.title){
    case "О приложении": Navigator.pushNamed(context, "/about"); break;
    case "Вход через VK": Navigator.pushNamed(context, "/auth"); break;
    case "Выйти из VK": bloc.logOut(); break;
    case "О нас": Navigator.pushNamed(context, "/about_us"); break;
  }
}
