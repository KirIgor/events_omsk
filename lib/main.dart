import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_vk_sdk/flutter_vk_sdk.dart';

import 'dart:io';

import 'package:omsk_events/bloc/bloc-widget.dart';
import 'package:omsk_events/bloc/event-details-bloc.dart';
import 'package:omsk_events/bloc/event-list-bloc.dart';
import 'package:omsk_events/bloc/event-map-bloc.dart';
import 'package:omsk_events/bloc/timetable-bloc.dart';
import 'package:omsk_events/bloc/user-bloc.dart';
import 'package:omsk_events/di.dart';
import 'package:omsk_events/ui/about-us-page.dart';
import 'package:omsk_events/ui/splash-page.dart';

import 'ui/event-list-page.dart';
import 'ui/map-page.dart';
import 'ui/timetable-list-page.dart';
import 'ui/settings-page.dart';
import 'ui/event-page.dart';
import 'ui/vk-auth-page.dart';
import 'ui/about-page.dart';

void main() async {
  try {
    await initializeDateFormatting("ru_RU");
    if (Platform.isIOS) {
      const String APP_ID = '6989563';
      const String API_VERSION = '5.90';

      final vkSdk =
          await VKSdk.initialize(appId: APP_ID, apiVersion: API_VERSION);
      DI.vkSdkProvider.setInstance(vkSdk);
    }

    runApp(App());
  } on VKSdkException catch (error) {
    print(error.message);
  }
}

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppState();
  }
}

class _AppState extends State<App> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  int _currentSelected = 0;

  bool _isSplashTime = true;

  @override
  void initState() {
    super.initState();
    firebaseCloudMessaging_Listeners();
  }

  void firebaseCloudMessaging_Listeners() {
    if (Platform.isIOS) iOS_Permission();

    _firebaseMessaging.subscribeToTopic("all");

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  void _onSelectItem(int selected) {
    setState(() {
      _currentSelected = selected;
    });
  }

  Widget getBody() {
    switch (_currentSelected) {
      case 0:
        return BlocWidget(
            bloc: EventListBloc(eventRepository: DI.eventRepository, settingRepository: DI.settingRepository),
            child: EventListPage());
      case 1:
        return BlocWidget(
            bloc: EventMapBloc(eventRepository: DI.eventRepository, settingRepository: DI.settingRepository),
            child: MapPage());
      case 2:
        return BlocWidget(
          bloc: UserBloc(),
          child: BlocWidget(
              bloc: TimetableBloc(
                  eventRepository: DI.eventRepository,
                  timetableRepository: DI.timetableRepository),
              child: TimetableListPage()),
        );
      case 3:
        return BlocWidget(bloc: UserBloc(), child: SettingsPage());
    }
    throw Exception("Invalid selected index");
  }

  Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).primaryColor;
  }

  Widget getScaffold(){
    return Scaffold(
        body: getBody(),
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentSelected,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.list), title: Text("События")),
              BottomNavigationBarItem(
                  icon: Icon(Icons.map), title: Text("Карта")),
              BottomNavigationBarItem(
                  icon: Icon(Icons.schedule), title: Text("Расписание")),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings), title: Text("Настройки"))
            ],
            onTap: _onSelectItem,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey));
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 1, milliseconds: 500)).then((v) {
      if (_isSplashTime)
      setState(() {
        _isSplashTime = false;
      });
    });

    return MaterialApp(
        onGenerateRoute: _onGenerateRoute,
        theme: ThemeData(
          primaryColor: Colors.lightBlue,
          primaryColorDark: Colors.blue,
          accentColor: Colors.blueAccent,
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
        ),
        home: _isSplashTime ? SplashPage() : getScaffold()
    );
  }

  Route _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/event_details":
        {
          int id = settings.arguments as int;
          return MaterialPageRoute(
              builder: (context) => BlocWidget(
                  bloc: UserBloc(),
                  child: BlocWidget(
                      bloc: EventDetailsBloc(
                          eventRepository: DI.eventRepository,
                          commentRepository: DI.commentRepository,
                          eventId: id),
                      child: EventPage(eventId: id))));
        }
      case "/map":
        return MaterialPageRoute(builder: (context) => MapPage());
      case "/settings":
        return MaterialPageRoute(builder: (context) => SettingsPage());
      case "/about":
        return MaterialPageRoute(builder: (context) => AboutPage());
      case "/auth":
        return MaterialPageRoute(
            builder: (context) =>
                BlocWidget(bloc: UserBloc(), child: VkAuthPage()));
      case "/about_us":
        return MaterialPageRoute(builder: (context) => AboutUsPage());
    }
    throw Exception("Invalid page");
  }
}
