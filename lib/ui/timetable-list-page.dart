import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:omsk_events/bloc/timetable-bloc.dart';
import 'package:omsk_events/bloc/user-bloc.dart';
import 'package:omsk_events/bloc/bloc-widget.dart';
import 'package:omsk_events/model/event-short.dart';
import 'package:omsk_events/ui/timetable-item.dart';

class TimetableListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TimetableListPageState();
}

class TimetableListPageState extends State<TimetableListPage> {
  TimetableBloc _timetableBloc;
  UserBloc _userBloc;

  bool _filterPast = true;

  @override
  void initState() {
    super.initState();

    _timetableBloc = BlocWidget.of(context);
    _userBloc = BlocWidget.of(context);

    _userBloc.userInfo.first.then((res) {
      if (res == null) Navigator.pushNamed(context, "/auth");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Избранное"),
        backgroundColor: Colors.white,
        actions: <Widget>[
          PopupMenuButton(
              tooltip: "Фильтрация",
              icon: Icon(Icons.filter_list),
              itemBuilder: (context) => [
                    CheckedPopupMenuItem(
                      child: Text("Убрать прошедшие"),
                      value: "filterPast",
                      checked: _filterPast,
                    )
                  ],
              onSelected: (value) {
                if (value == "filterPast") {
                  _timetableBloc.changeFilterPast(!_filterPast);
                  setState(() {
                    _filterPast = !_filterPast;
                  });
                }
              }),
        ],
      ),
      body: RefreshIndicator(
          child: StreamBuilder(
              stream: _timetableBloc.timetable,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<EventShort> timetable = snapshot.data;
                  if (timetable.isNotEmpty)
                    return ListView.separated(
                      separatorBuilder: (context, position) => Divider(),
                      itemBuilder: (context, position) => Dismissible(
                            key: Key(timetable[position].id.toString()),
                            child: TimetableItem(event: timetable[position]),
                            direction: DismissDirection.endToStart,
                            onDismissed: (dir) => _timetableBloc
                                .removeFromTimetable(timetable[position].id),
                            background: Container(
                              color: Colors.red,
                              child: Container(
                                child: Icon(Icons.delete, color: Colors.white),
                                margin: EdgeInsets.only(right: 32),
                              ),
                              alignment: Alignment.centerRight,
                            ),
                          ),
                      itemCount: timetable.length,
                    );
                  return Center(
                      child: Container(
                          height: 130,
                          child: Column(children: <Widget>[
                            Icon(Icons.event_busy,
                                size: 64, color: Colors.black45),
                            Text(
                              "Вы можете собрать на этой странице самые интересные события, чтобы ничего не пропустить!",
                              style: TextStyle(
                                  color: Colors.black45, fontSize: 16),
                              textAlign: TextAlign.center,
                            )
                          ])));
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
          onRefresh: _timetableBloc.loadTimetable),
    );
  }
}
