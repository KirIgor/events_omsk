import 'dart:async';

import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:omsk_events/model/event-short.dart';
import 'package:omsk_events/model/event.dart';
import 'package:omsk_events/model/setting.dart';
import 'package:omsk_events/resources/repositories/abstract/event-repository.dart';
import 'package:omsk_events/resources/repositories/abstract/setting-repository.dart';
import 'package:rxdart/rxdart.dart';

import 'bloc-base.dart';

class EventListBloc extends BlocBase {
  final EventRepository _eventRepository;
  final SettingRepository _settingRepository;

  EventListBloc(
      {@required EventRepository eventRepository,
      @required SettingRepository settingRepository})
      : _eventRepository = eventRepository,
        _settingRepository = settingRepository;

  bool _isBig;
  EventOrderBy _orderBy = EventOrderBy.startDateTime;
  String _query;
  EventOrderType _orderType = EventOrderType.ASC;

  final _settingsFetcher = PublishSubject<List<Setting>>();

  Observable<List<Setting>> get allSettings => _settingsFetcher.stream;

  Future<List<EventShort>> fetchNewEvents(int page) async {
    if (_query == null || _query.isEmpty) {
      return await _eventRepository.fetchEvents(
        page: page,
        pageSize: 5,
        orderBy: _orderBy,
        orderType: _orderType,
        filter: {"isBig": _isBig, "withoutPast": true},
      );
    }

    return await _eventRepository.fetchEvents(
      page: page,
      pageSize: 5,
      orderBy: _orderBy,
      orderType: _orderType,
      filter: {"name": _query, "isBig": _isBig, "withoutPast": true},
    );
  }

  Future<void> refresh() async {
    await fetchNewEvents(0);
  }

  void setOrderBy(EventOrderBy value) async {
    _orderBy = value;
    switch (_orderBy) {
      case EventOrderBy.likesCount:
        _orderType = EventOrderType.DESC;
        break;
      case EventOrderBy.startDateTime:
        _orderType = EventOrderType.ASC;
        break;
    }
  }

  void setSearchQuery(String query) {
    _query = query;
  }

  void changeBigFilter(bool isBig) {
    if (isBig)
      _isBig = true;
    else
      _isBig = null;
  }

  Future<void> fetchAllSettings() async {
    // TODO: pageSize -1 on backend
    List<Setting> settings = await _settingRepository.fetchSettings();
    _settingsFetcher.sink.add(settings);
  }

  @override
  void init() {
    fetchAllSettings();
  }

  @override
  void dispose() {
    super.dispose();
    _settingsFetcher.close();
  }
}
