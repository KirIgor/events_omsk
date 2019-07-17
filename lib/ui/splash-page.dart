import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const textStyle = TextStyle(fontSize: 22);

class SplashPage extends StatelessWidget {
  const SplashPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          fit: StackFit.expand,
          alignment: AlignmentDirectional.bottomCenter,
          children: <Widget>[
            Container(height: 380, child: Image.asset("assets/omsk_icon.png")),
            Positioned(
                bottom: 10,
                child: Column(
                  children: <Widget>[
                    Text(
                      "Онлайн-гид по главным",
                      style: textStyle,
                    ),
                    Text(
                      "городским мероприятиям",
                      style: textStyle,
                    )
                  ],
                ))
          ],
        ));
  }
}
