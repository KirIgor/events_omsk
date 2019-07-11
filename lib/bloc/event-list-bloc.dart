import 'package:meta/meta.dart';
import 'package:omsk_events/model/event-short.dart';
import 'package:omsk_events/model/event.dart';
import 'package:omsk_events/resources/repositories/abstract/event-repository.dart';
import 'package:rxdart/rxdart.dart';

import 'bloc-base.dart';

class EventListBloc extends BlocBase {
  final EventRepository _repository;

  EventListBloc({@required EventRepository repository})
      : _repository = repository;

  final _eventsFetcher = PublishSubject<List<EventShort>>();
  final _loadingSubject = PublishSubject<bool>();
  OrderBy orderBy = OrderBy.likesCount;

  Observable<List<EventShort>> get allEvents => _eventsFetcher.stream;

  Observable<bool> get isNewEventsLoading => _loadingSubject.stream;

  final List<EventShort> loadedEvents = List();

  Future<List<EventShort>> fetchNewEvents(int page) async {
    return await _repository.fetchEvents(
        page: page, pageSize: 5, orderBy: orderBy);
  }

  Future<void> refresh() async {
    loadedEvents.clear();
    await fetchNewEvents(0);
  }

  @override
  void dispose() {
    _eventsFetcher.close();
    _loadingSubject.close();
  }

  void setOrderBy(OrderBy value) async {
    orderBy = value;
    refresh();
  }
}
