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
      body: RefreshIndicator(
          child: StreamBuilder(
              stream: _timetableBloc.timetable,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<EventShort> timetable = snapshot.data;
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
