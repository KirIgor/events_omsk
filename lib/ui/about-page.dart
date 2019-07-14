import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

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
                borderRadius: BorderRadius.circular(10000.0),

                child: Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: BoxDecoration(
                      gradient: new LinearGradient(
                        colors: [
                          Color(0xA8000000),
                          Color(0xA8000000),
                        ],
                      ),
                    ),
                    child: Image(
                      fit: BoxFit.fill,
                      image: AssetImage("assets/logo.png"),
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
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Text(
                  "Приложение информирует о значимых городских мероприятиях - "
                  "в поле зрения редакции попадают события Дня города, Нового года, Масленицы, Дня Победы и другие"
                  "Ленту событий формируют структурные подразделения Администрации города Омска:\n",
                  style: TextStyle(color: Colors.black54),
                ),
                InkWell(
                    child: Text("-департамент информационной политики",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline)),
                    onTap: () => _firstLink()),
                InkWell(
                    child: Text(
                      "-управление информационно-коммуникационных технологии\n",
                      style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                    ),
                    onTap: () => _secondLink()),
                Text(
                    "Возможные изменения места проведения, времени начала мероприятий оперативно отражаются в приложении. "
                    "Планируйте собственные праздничные маршруты с удобством и удовольствием",
                    style: TextStyle(color: Colors.black54)),
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

  void _privacyPolicy() {}

  void _share() {
    const appUrl = "<Здесь будет ссылка>";

    //TODO(Change app url)
    Share.plainText(
            title: "Карта праздничных мероприятий Омска",
            text:
                "Скачайте приложение с $appUrl и будьте в курсе всех праздничных мероприятий в гооде")
        .share();
  }

  void _rateApp() {}

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
