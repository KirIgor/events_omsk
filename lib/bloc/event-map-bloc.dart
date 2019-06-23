import 'package:meta/meta.dart';
import 'package:omsk_events/model/event-short.dart';
import 'package:omsk_events/resources/repositories/abstract/event-repository.dart';
import 'package:rxdart/rxdart.dart';

import 'bloc-base.dart';

class EventMapBloc extends BlocBase {
  final EventRepository _repository;
  EventMapBloc({@required EventRepository repository}) : _repository = repository;

  final _eventsFetcher = PublishSubject<List<EventShort>>();

  Observable<List<EventShort>> get allEvents => _eventsFetcher.stream;
  
  Future<void> fetchAllEvents() async {
    List<EventShort> events = await _repository.fetchEvents(pageSize: 1000);
    _eventsFetcher.sink.add(events);
  }

  @override
  void dispose() {
    _eventsFetcher.close();
  }

  @override
  void init() {
    fetchAllEvents();
  }
}
