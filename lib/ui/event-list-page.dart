import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:omsk_events/bloc/bloc-widget.dart';
import 'package:omsk_events/bloc/event-list-bloc.dart';
import 'package:omsk_events/model/event-short.dart';
import 'package:omsk_events/model/event.dart';
import 'package:loader_search_bar/loader_search_bar.dart';
import 'package:rxdart/rxdart.dart';

import 'event-item.dart';

class EventListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EventListState();
  }
}

class _EventListState extends State<EventListPage> {
  PagewiseLoadController<EventShort> _pagewiseLoadController;
  SearchBarController _searchController;
  EventListBloc _bloc;
  final searchStream = PublishSubject<String>();

  void setSearchQuery(String query){
    _bloc.setSearchQuery(query);
    _pagewiseLoadController.reset();
  }


  @override
  Widget build(BuildContext context) {
    _bloc = BlocWidget.of<EventListBloc>(context);

    _pagewiseLoadController = PagewiseLoadController<EventShort>(
        pageFuture: (pageIndex) {
          return _bloc.fetchNewEvents(pageIndex);
        },
        pageSize: 5);

    final pagewiseList = PagewiseListView<EventShort>(
        pageLoadController: _pagewiseLoadController,
        itemBuilder: (context, event, index) => EventItem(event: event));

    _searchController = SearchBarController(
      onClearQuery: () { setSearchQuery(""); _searchController.clearQuery(); },
      onCancelSearch: () { setSearchQuery(""); _searchController.cancelSearch();},
    );

    searchStream.stream
        .debounce(Duration(milliseconds: 800))
        .listen((query){
          setSearchQuery(query);
        });

    return Scaffold(
        appBar: SearchBar(
            controller: _searchController,
            onQueryChanged: (query) {
              searchStream.add(query);
            },
            searchHint: "Название события",
            defaultBar: AppBar(
                backgroundColor: Colors.white,
                title: Text("Список событий"),
                actions: <Widget>[
                  PopupMenuButton(
                      tooltip: "Сортировка",
                      icon: Icon(Icons.sort),
                      itemBuilder: (context) => [
                            PopupMenuItem(
                                child: Text("По дате"),
                                value: OrderBy.startDateTime),
                            PopupMenuItem(
                                child: Text("По количеству лайков"),
                                value: OrderBy.likesCount)
                          ],
                      onSelected: (value) {
                        _bloc.setOrderBy(value);
                        _pagewiseLoadController.reset();
                      })
                ])),
        body: pagewiseList);
  }

  @override
  void dispose() {
    _pagewiseLoadController.dispose();
    searchStream.close();
    super.dispose();
  }
}
