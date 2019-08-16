import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:io';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title:
              new Text("О приложении", style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
            child: new Column(children: <Widget>[
          new Container(
            padding: const EdgeInsets.all(52.0),
            child: new Column(children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),

                child: Container(
                    child: Image(
                  fit: BoxFit.fill,
                  image: AssetImage("assets/omsk_icon.png"),
                ) //image
                    ), //container im
              ), //cliprr
              new Container(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Омск: город сегодня",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            ]),
            alignment: FractionalOffset.topCenter,
          ),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Приложение «Омск: город сегодня» информирует о значимых городских мероприятиях. "
                      "В поле зрения редакции попадают события как масштабные, уникальные, "
                      "привлекающие внимание огромного количества людей, так и небольшие, "
                      "но от этого не менее интересные и важные.\n",
                      style: TextStyle(color: Colors.black54),
                    ),
                    Wrap(children: <Widget>[
                      Text(
                          "Ленту событий формируют структурные подразделения Администрации города Омска:  ",
                          style: TextStyle(color: Colors.black54)),
                      ListTile(
                          title: Text("— департамент информационной политики",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontSize: 14)),
                          onTap: _firstLink),
                      ListTile(
                          title: Text(
                              "— управления информационно-коммуникационных технологий",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontSize: 14)),
                          onTap: _secondLink)
                    ]),
                    Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Text(
                            "Возможные изменения места проведения, времени начала мероприятий оперативно отражаются в приложении.",
                            style: TextStyle(color: Colors.black54))),
                    Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Text(
                            "Будьте в курсе всего самого интересного! Планируйте свой досуг в Омске с удобством и удовольствием.",
                            style: TextStyle(color: Colors.black54)))
                  ])),
          Divider(),
          ListTile(
              leading: Icon(Icons.star),
              title: Text("Оценить приложение"),
              onTap: () => _rateApp()),
          ListTile(
              leading: Icon(Icons.info),
              title: Text("Политика конфиденциальности"),
              onTap: () => _privacyPolicy()),
          ListTile(
              leading: Icon(Icons.share),
              title: Text("Поделиться приложением"),
              onTap: () => _share())
        ]) //Column
            ) //cont

        ); //scaffold
  }

  void _privacyPolicy() {
    const url = "https://events.admomsk.ru/privacy_policy";
    launch(url);
  }

  void _share() {
    if(Platform.isAndroid) {
      const appUrl =
          "https://play.google.com/store/apps/details?id=ru.admomsk.omsk_events&hl=ru";

      Share.plainText(
          title: "Карта праздничных мероприятий Омска",
          text:
          "Скачайте приложение с $appUrl и будьте в курсе всех праздничных мероприятий в городе")
          .share();
    }
  }

  void _rateApp() {
    if(Platform.isAndroid) {
      const url =
          "https://play.google.com/store/apps/details?id=ru.admomsk.omsk_events&hl=ru";
      launch(url);
    }
  }

  void _firstLink() {
    const url = "https://admomsk.ru/web/guest/government/divisions/45/about";
    launch(url);
  }

  void _secondLink() {
    const url =
        "https://admomsk.ru/web/guest/government/divisions/47/technologies/about";
    launch(url);
  }
}
