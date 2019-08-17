import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:intl/intl.dart';
import 'package:omsk_events/bloc/bloc-widget.dart';
import 'package:omsk_events/bloc/event-list-bloc.dart';
import 'package:omsk_events/model/event-short.dart';
import 'package:omsk_events/model/event.dart';
import 'package:loader_search_bar/loader_search_bar.dart';
import 'package:omsk_events/model/setting.dart';
import 'package:rxdart/rxdart.dart';
import 'package:omsk_events/utils/utils.dart';
import '../di.dart';
import 'event-item.dart';

class _ListTile extends StatelessWidget {
  final Widget leading;
  final Widget title;

  const _ListTile({Key key, this.leading, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
        style: TextStyle(fontSize: 16, color: Colors.black),
        child: Container(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: Row(
              children: <Widget>[
                Container(
                  child: leading,
                  margin: EdgeInsets.only(left: 25),
                ),
                Container(
                  child: title,
                  margin: EdgeInsets.only(left: 20),
                )
              ],
            )));
  }
}

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
  bool isBig = false;
  bool isFree = false;
  List<Setting> _settings;

  final searchStream = PublishSubject<String>();

  @override
  void initState() {
    super.initState();

    _bloc = BlocWidget.of<EventListBloc>(context);

    _pagewiseLoadController = PagewiseLoadController<EventShort>(
        pageFuture: (pageIndex) {
          return _bloc.fetchNewEvents(pageIndex);
        },
        pageSize: 10);

    _searchController = SearchBarController(
      onClearQuery: () {
        setSearchQuery("");
        _searchController.clearQuery();
      },
      onCancelSearch: () {
        setSearchQuery("");
        _searchController.cancelSearch();
      },
    );

    searchStream.stream.debounce(Duration(milliseconds: 800)).listen((query) {
      setSearchQuery(query);
    });
  }

  void setSearchQuery(String query) {
    _bloc.setSearchQuery(query);
    _pagewiseLoadController.reset();
  }

  void _showHelp(List<Setting> settings) {
    final specialDate1 = DI.dateConverter.convert(DateTime.parse(settings
        .firstWhere((setting) => setting.key == "SPECIAL_DATE_1")
        .value));
    final specialDate2 = DI.dateConverter.convert(DateTime.parse(settings
        .firstWhere((setting) => setting.key == "SPECIAL_DATE_2")
        .value));
    final specialDate3 = DI.dateConverter.convert(DateTime.parse(settings
        .firstWhere((setting) => setting.key == "SPECIAL_DATE_3")
        .value));

    final specialDate1Color =
        settings.firstWhere((setting) => setting.key == "SPECIAL_DATE_1_COLOR");
    final specialDate2Color =
        settings.firstWhere((setting) => setting.key == "SPECIAL_DATE_2_COLOR");
    final specialDate3Color =
        settings.firstWhere((setting) => setting.key == "SPECIAL_DATE_3_COLOR");

    final title =
        settings.firstWhere((setting) => setting.key == "TITLE").value;

    final specialDateFormat = DateFormat("d MMMM, E", "ru_RU");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        const radius = 8.0;

        return SimpleDialog(
          title: Text(
            "Цветовое кодирование",
          ),
          children: <Widget>[
            _ListTile(
              leading:
                  CircleAvatar(backgroundColor: Colors.green, radius: radius),
              title: Text("Сегодня"),
            ),
            Container(
              height: 1,
              color: Colors.black26,
              margin: EdgeInsets.only(left: 10, right: 10),
            ),
            Container(
              margin: EdgeInsets.only(top: 10, left: 25, bottom: 10),
              child: Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            _ListTile(
              leading: CircleAvatar(
                  backgroundColor: specialDate1Color.getSpecialDateColor(),
                  radius: radius),
              title: Text(specialDateFormat.format(specialDate1)),
            ),
            _ListTile(
              leading: CircleAvatar(
                  backgroundColor: specialDate2Color.getSpecialDateColor(),
                  radius: radius),
              title: Text(specialDateFormat.format(specialDate2)),
            ),
            _ListTile(
              leading: CircleAvatar(
                  backgroundColor: specialDate3Color.getSpecialDateColor(),
                  radius: radius),
              title: Text(specialDateFormat.format(specialDate3)),
            ),
            _ListTile(
              leading:
                  CircleAvatar(backgroundColor: Colors.purple, radius: radius),
              title: Text("Многодневные"),
            ),
            Container(
                height: 1,
                color: Colors.black26,
                margin:
                    EdgeInsets.only(top: 10, bottom: 5, left: 10, right: 10)),
            _ListTile(
              leading:
                  CircleAvatar(backgroundColor: Colors.yellow, radius: radius),
              title: Text("В другие дни"),
            ),
          ],
        );
      },
    );
  }

  Widget buildEventItem(EventShort event, List<Setting> settings) {
    final markerColor = getEventMarkerColor(settings, event);
    return EventItem(event: event, markerColor: markerColor);
  }

  @override
  Widget build(BuildContext context) {
    final pagewiseList = PagewiseListView<EventShort>(
        pageLoadController: _pagewiseLoadController,
        itemBuilder: (context, event, index) =>
            buildEventItem(event, _settings));

    return StreamBuilder(
        stream: _bloc.allSettings,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _settings = snapshot.data;
            return Scaffold(
                appBar: SearchBar(
                    controller: _searchController,
                    onQueryChanged: (query) {
                      searchStream.add(query);
                    },
                    searchHint: "Название события",
                    defaultBar: AppBar(
                      backgroundColor: Colors.white,
                      title: Text("События"),
                      actions: <Widget>[
                        IconButton(
                            icon: Icon(Icons.help_outline),
                            onPressed: () => _showHelp(_settings)),
                        PopupMenuButton(
                            tooltip: "Сортировка",
                            icon: Icon(Icons.sort),
                            itemBuilder: (context) => [
                                  PopupMenuItem(
                                      child: Text("По дате"),
                                      value: EventOrderBy.startDateTime),
                                  PopupMenuItem(
                                      child: Text("По числу участников"),
                                      value: EventOrderBy.likesCount)
                                ],
                            onSelected: (value) {
                              _bloc.setOrderBy(value);
                              _pagewiseLoadController.reset();
                            }),
                        PopupMenuButton(
                          tooltip: "Фильтрация",
                          icon: Icon(Icons.filter_list),
                          itemBuilder: (context) => [
                            CheckedPopupMenuItem(
                              child: Text("Только масштабные"),
                              value: "big",
                              checked: isBig,
                            ),
                            CheckedPopupMenuItem(
                              child: Text("Только бесплатные"),
                              value: "free",
                              checked: isFree,
                            )
                          ],
                          onSelected: (value) {
                            if (value == "big") {
                              _bloc.changeBigFilter(!isBig);
                              setState(() {
                                isBig = !isBig;
                              });
                              _pagewiseLoadController.reset();
                            } else if (value == "free") {
                              _bloc.changeFreeFilter(!isFree);
                              setState(() {
                                isFree = !isFree;
                              });
                              _pagewiseLoadController.reset();
                            }
                          },
                        )
                      ],
                    )),
                body: RefreshIndicator(
                    child: pagewiseList,
                    onRefresh: () async {
                      _pagewiseLoadController.reset();
                      await Future.value({});
                    }));
          } else
            return Center(child: CircularProgressIndicator());
        });
  }

  @override
  void dispose() {
    _pagewiseLoadController.dispose();
    searchStream.close();
    super.dispose();
  }
}
