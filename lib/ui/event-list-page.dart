import 'package:flutter/material.dart';
import 'package:omsk_events/bloc/bloc-widget.dart';
import 'package:omsk_events/bloc/event-list-bloc.dart';
import 'package:omsk_events/model/event-short.dart';

import 'event-item.dart';

class EventListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = BlocWidget.of<EventListBloc>(context);

    return Scaffold(
        body: RefreshIndicator(
            child: StreamBuilder(
              stream: bloc.allEvents,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<EventShort> events = snapshot.data;
                  return NotificationListener(
                      child: StreamBuilder(
                          stream: bloc.isNewEventsLoading,
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data == true) {
                              return ListView.builder(
                                  itemCount: events.length + 1,
                                  itemBuilder: (context, position) {
                                    if (position < events.length)
                                      return EventItem(event: events[position]);
                                    return Container(
                                        width: double.infinity,
                                        height: 100,
                                        child: Center(
                                            child:
                                                CircularProgressIndicator()));
                                  });
                            }
                            return ListView.builder(
                                itemCount: events.length,
                                itemBuilder: (context, position) =>
                                    EventItem(event: events[position]));
                          }),
                      onNotification: (t) {
                        if (t is ScrollEndNotification) {
                          bloc.fetchNewEvents();
                        }
                      });
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
            onRefresh: bloc.fetchNewEvents));
  }
}
