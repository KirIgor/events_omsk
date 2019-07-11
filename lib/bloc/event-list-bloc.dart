import 'package:meta/meta.dart';
import 'package:omsk_events/model/event-short.dart';
import 'package:omsk_events/model/event.dart';
import 'package:omsk_events/resources/repositories/abstract/event-repository.dart';

import 'bloc-base.dart';

class EventListBloc extends BlocBase {
  final EventRepository _repository;

  EventListBloc({@required EventRepository repository})
      : _repository = repository;

  OrderBy _orderBy = OrderBy.likesCount;
  String _query;

  Future<List<EventShort>> fetchNewEvents(int page) async {
    if (_query == null || _query.isEmpty) {
      return await _repository.fetchEvents(
          page: page, pageSize: 5, orderBy: _orderBy);
    }

    return await _repository.fetchEvents(
        page: page, pageSize: 5, orderBy: _orderBy, filter: {"name": _query});
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
}
