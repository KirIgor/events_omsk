import 'dart:async';

import 'package:meta/meta.dart';
import 'package:omsk_events/model/event-short.dart';
import 'package:omsk_events/resources/repositories/abstract/event-repository.dart';
import 'package:omsk_events/resources/repositories/abstract/timetable-repository.dart';
import 'package:rxdart/rxdart.dart';

import 'bloc-base.dart';

class TimetableBloc extends BlocBase {
  final TimetableRepository _timetableRepository;
  final EventRepository _eventRepository;
  final _timetableFetcher = PublishSubject<List<EventShort>>();
  Observable<List<EventShort>> get timetable => _timetableFetcher.stream;
  List<EventShort> _currentTimetable;

  TimetableBloc({@required TimetableRepository timetableRepository, @required EventRepository eventRepository})
      : _timetableRepository = timetableRepository, _eventRepository = eventRepository;

  Future<void> loadTimetable() {
    return _timetableRepository.fetchTimetable().then((timetable) {
      _currentTimetable = timetable;
      _timetableFetcher.add(timetable);
    });
  }

  void removeFromTimetable(int eventId) {
    _eventRepository.dislikeEvent(eventId);
    _currentTimetable.removeWhere((event) => event.id == eventId);
    _timetableFetcher.add(_currentTimetable);
  }

  @override
  void init() {
    loadTimetable();
  }

  @override
  void dispose() {
    super.dispose();
    _timetableFetcher.close();
  }
}
