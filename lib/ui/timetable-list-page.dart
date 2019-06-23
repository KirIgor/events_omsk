import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:omsk_events/bloc/bloc-widget.dart';
import 'package:omsk_events/bloc/timetable-bloc.dart';
import 'package:omsk_events/model/event-short.dart';
import 'package:omsk_events/model/event.dart';
import 'package:omsk_events/ui/timetable-item.dart';

import '../di.dart';

class TimetableListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var bloc = TimetableBloc(eventRepository: DI.eventRepository, timetableRepository: DI.timetableRepository);

    return BlocWidget(
        bloc: bloc,
        child: Scaffold(
          body: RefreshIndicator(
              child: StreamBuilder(
                  stream: bloc.timetable,
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      List<EventShort> timetable = snapshot.data;
                      return ListView.separated(
                        separatorBuilder: (context, position) => Divider(),
                        itemBuilder: (context, position) => Dismissible(
                              key: Key(timetable[position].id.toString()),
                              child: TimetableItem(
                                  event: timetable[position]),
                              direction: DismissDirection.endToStart,
                              onDismissed: (dir) => bloc
                                  .removeFromTimetable(timetable[position].id),
                              background: Container(
                                color: Colors.red,
                                child: Container(
                                  child:
                                      Icon(Icons.delete, color: Colors.white),
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
              onRefresh: bloc.loadTimetable),
        ));
  }
}
