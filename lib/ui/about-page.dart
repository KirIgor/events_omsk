import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        //  appBar: AppBar(
        //  title: new Text('О приложении'),
        // ),
        //    backgroundColor:Color(0xffb5ffff),
        body: SizedBox.expand(
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
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
          new Container(
              padding: const EdgeInsets.only(bottom: 48.0),
              child: SizedBox(
                height: 50,
                child: FlatButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  disabledColor: Colors.grey,
                  disabledTextColor: Colors.black,
                  // padding: EdgeInsets.all(8.0),
                  splashColor: Color(0xff49a7cc), //0xff80d8ff
                  onPressed: () {
                    //to do
                  },
                  child: Text(
                    "Оценить приложение",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
              ),
              alignment: FractionalOffset.bottomCenter)
        ]) //Column
            ) //cont

        ); //scaffold
  }
}
