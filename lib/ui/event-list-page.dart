import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:omsk_events/bloc/bloc-widget.dart';
import 'package:omsk_events/bloc/event-list-bloc.dart';
import 'package:omsk_events/model/event-short.dart';
import 'package:omsk_events/model/event.dart';

import 'event-item.dart';

class EventListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EventListState();
  }
}

class _EventListState extends State<EventListPage> {
  PagewiseLoadController<EventShort> _pagewiseLoadController;

  @override
  Widget build(BuildContext context) {
    final bloc = BlocWidget.of<EventListBloc>(context);

    _pagewiseLoadController = PagewiseLoadController<EventShort>(
        pageFuture: (pageIndex) {
          return bloc.fetchNewEvents(pageIndex);
        },
        pageSize: 5);

    final pagewiseList = PagewiseListView<EventShort>(
        pageLoadController: _pagewiseLoadController,
        itemBuilder: (context, event, index) => EventItem(event: event));

    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text("Список событий"),
            actions: <Widget>[
              PopupMenuButton(
                  tooltip: "Сортировка",
                  icon: Icon(Icons.sort),
                  itemBuilder: (context) => [
                        PopupMenuItem(
                            child: Text("По дате"),
                            value: OrderBy.START_DATE_TIME),
                        PopupMenuItem(
                            child: Text("По количеству лайков"),
                            value: OrderBy.LIKES_COUNT)
                      ],
                  onSelected: (value) {
                    bloc.setOrderBy(value);
                    _pagewiseLoadController.reset();
                  })
            ]),
        body: pagewiseList);
  }

  @override
  void dispose() {
    _pagewiseLoadController.dispose();
    super.dispose();
  }
}
