import 'package:flutter/material.dart';
import 'package:share/share.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title:
              new Text('О приложении', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
        ),
        body: SizedBox.expand(
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
                      image: AssetImage('assets/logo.png'),
                    ) //image
                    ), //container im
              ), //cliprr
              new Container(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Карта праздничных мероприятий Омска',
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
          Divider(),
          ListTile(
              leading: Icon(Icons.star), title: Text("Оценить приложение"), onTap: () => rateApp()),
          ListTile(
              leading: Icon(Icons.info),
              title: Text("Политика конфиденциальности"), onTap: () =>_privacyPolicy()),
          ListTile(
              leading: Icon(Icons.share), title: Text("Поделиться приложением"), onTap: () => _share())
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
        text: "Скачайте приложение с $appUrl и будьте в курсе всех праздничных мероприятий в гооде")
        .share();
  }

  void rateApp() {}
}
