import 'package:meta/meta.dart';
import 'package:omsk_events/model/event-short.dart';
import 'package:omsk_events/resources/repositories/abstract/event-repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';

import 'bloc-base.dart';

class EventListBloc extends BlocBase {
  final EventRepository _repository;
  EventListBloc({@required EventRepository repository})
      : _repository = repository;

  final _eventsFetcher = PublishSubject<List<EventShort>>();
  final _loadingSubject = PublishSubject<bool>();

  Observable<List<EventShort>> get allEvents => _eventsFetcher.stream;
  Observable<bool> get isNewEventsLoading => _loadingSubject.stream;

  final List<EventShort> loadedEvents = List();
  int _currentPage = 0;
  final _lock = Lock();

  Future<void> fetchNewEvents() async {
    return await _lock.synchronized(() async {
      _loadingSubject.add(true);
      List<EventShort> events =
          await _repository.fetchEvents(page: _currentPage, pageSize: 6);
      loadedEvents.addAll(events);
      _currentPage++;
      _loadingSubject.add(false);
      _eventsFetcher.sink.add(loadedEvents);
    }, timeout: Duration(microseconds: 0));
  }

  Future<void> refresh() async {
    _currentPage = 0;
    loadedEvents.clear();
    await fetchNewEvents();
  }

  @override
  void dispose() {
    _eventsFetcher.close();
    _loadingSubject.close();
  }

  @override
  void init() async {
    refresh();
  }
}
