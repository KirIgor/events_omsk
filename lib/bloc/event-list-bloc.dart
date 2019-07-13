import 'dart:async';

import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:omsk_events/model/event-short.dart';
import 'package:omsk_events/model/event.dart';
import 'package:omsk_events/resources/repositories/abstract/event-repository.dart';

import 'bloc-base.dart';

class EventListBloc extends BlocBase {
  final EventRepository _eventRepository;

  EventListBloc({@required EventRepository eventRepository})
      : _eventRepository = eventRepository;

  OrderBy _orderBy = OrderBy.likesCount;
  String _query;
  bool _filterPast = false;

  Future<List<EventShort>> fetchNewEvents(int page) async {
    final startDate =
        _filterPast ? DateTime.now() : DateTime.fromMicrosecondsSinceEpoch(0);
    final startDateString = DateFormat("yyyy-MM-dd").format(startDate);

    if (_query == null || _query.isEmpty) {
      return await _eventRepository.fetchEvents(
          page: page,
          pageSize: 5,
          orderBy: _orderBy,
          filter: {"fromStartDate": startDateString},
          followSettings: false);
    }

    return await _eventRepository.fetchEvents(
        page: page,
        pageSize: 5,
        orderBy: _orderBy,
        filter: {"name": _query, "fromStartDate": startDateString},
        followSettings: false);
  }

  Future<void> refresh() async {
    await fetchNewEvents(0);
  }

  void setOrderBy(OrderBy value) async {
    _orderBy = value;
    refresh();
  }

  void setSearchQuery(String query) {
    _query = query;
  }

  void changeFilterPast(bool value) {
    _filterPast = value;
    refresh();
  }
}
