import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("О нас", style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.white),
        body: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              Text("Разработчики", style: TextStyle(fontSize: 20)),
              Divider(),
              ListTile(
                  leading: CircleAvatar(
                      backgroundImage: AssetImage("assets/igor.png")),
                  title: Text("Кирьянов Игорь"),
                  onTap: () => _openIgor(),
                  subtitle: Text("ОмГУ, 3 курс")),
              ListTile(
                  leading: CircleAvatar(
                      backgroundImage: AssetImage("assets/daniil.png")),
                  title: Text("Бугай Даниил"),
                  onTap: () => _openDaniil(),
                  subtitle: Text("ОмГУ, 3 курс")),
              ListTile(
                  leading: CircleAvatar(
                      backgroundImage: AssetImage("assets/tanya.png")),
                  title: Text("Олейникова Татьяна"),
                  onTap: () => _openTanya(),
                  subtitle: Text("ОмГУ, 3 курс")),
              ListTile(
                  leading: CircleAvatar(
                      backgroundImage: AssetImage("assets/effective.png")),
                  title: Text("Компания Effective"),
                  onTap: () => _openEffective(),
                  subtitle: Text("<О Effective>"))
            ],
          ),
        ));
  }

  void _openEffective() async {
    const url = "https://effective.band/";
    launch(url);
  }

  void _openTanya() async {
    const url = "https://vk.com/tanyaoleynikova";
    launch(url);
  }

  void _openDaniil() async {
    const url = "https://vk.com/id99117046";
    launch(url);
  }

  void _openIgor() async {

  }
}
