import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:omsk_events/ui/event-page.dart';
import 'package:omsk_events/ui/timetable-list-page.dart';
import 'package:omsk_events/bloc/bloc-widget.dart';
import 'package:omsk_events/bloc/event-details-bloc.dart';
import 'package:omsk_events/bloc/event-list-bloc.dart';
import 'package:omsk_events/di.dart';
import 'event-list-page.dart';
import 'map-page.dart';

main() => initializeDateFormatting("ru_RU").then((_) => runApp(App()));

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppState();
  }
}

class _AppState extends State<App> {
  int _currentSelected = 0;

  void _onSelectItem(int selected) {
    setState(() {
      _currentSelected = selected;
    });
  }

  Widget getBody() {
    switch (_currentSelected) {
      case 0:
        return BlocWidget(
            bloc: EventListBloc(repository: DI.eventRepository),
            child: EventListPage());
      case 1:
        return MapPage();
      case 2:
        return TimetableListPage();
      case 3:
        return EventListPage();
    }
    throw Exception("Invalid selected index");
  }

  Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        onGenerateRoute: _onGenerateRoute,
        theme: ThemeData(
          primaryColor: Colors.lightBlue,
          primaryColorDark: Colors.blue,
          accentColor: Colors.blueAccent,
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
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
                unselectedItemColor: Colors.grey)));
  }

  Route _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/all_events":
        return MaterialPageRoute(
            builder: (context) => BlocWidget(
                bloc: EventListBloc(repository: DI.eventRepository),
                child: EventListPage()));
      case "/event_details":
        {
          int id = settings.arguments as int;
          return MaterialPageRoute(
              builder: (context) => BlocWidget<EventDetailsBloc>(
                  bloc: EventDetailsBloc(
                      eventRepository: DI.eventRepository,
                      commentRepository: DI.commentRepository,
                      eventId: id),
                  child: EventPage(eventId: id)));
        }
      case "/map":
        return MaterialPageRoute(builder: (context) => MapPage());
      case "/settings":
        break;
    }
    throw Exception("Invalid page");
  }
}
