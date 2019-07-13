import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

import 'package:omsk_events/model/event-short.dart';
import 'package:omsk_events/model/setting.dart';
import 'package:omsk_events/resources/repositories/abstract/event-repository.dart';
import 'package:omsk_events/resources/repositories/abstract/setting-repository.dart';
import 'package:rxdart/rxdart.dart';

import 'bloc-base.dart';

class EventMapBloc extends BlocBase {
  final EventRepository _eventRepository;
  final SettingRepository _settingRepository;

  EventMapBloc(
      {@required EventRepository eventRepository,
      @required SettingRepository settingRepository})
      : _eventRepository = eventRepository,
        _settingRepository = settingRepository;

  final _eventsFetcher = PublishSubject<List<EventShort>>();
  final _settingsFetcher = PublishSubject<List<Setting>>();

  Observable<List<EventShort>> get allEvents => _eventsFetcher.stream;
  Observable<List<Setting>> get allSettings => _settingsFetcher.stream;

  Future<List<EventShort>> fetchAllEvents() async {
    List<EventShort> events = await _eventRepository.fetchEvents(pageSize: -1);
    _eventsFetcher.sink.add(events);
    return events;
  }

  Future<void> fetchAllSettings() async {
    // TODO: pageSize -1 on backend
    List<Setting> settings = await _settingRepository.fetchSettings();
    _settingsFetcher.sink.add(settings);
  }

  @override
  void dispose() {
    _eventsFetcher.close();
    _settingsFetcher.close();
  }

  @override
  void init() {
    fetchAllSettings();
    fetchAllEvents();
  }
}
