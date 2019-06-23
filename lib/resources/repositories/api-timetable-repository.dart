import 'package:omsk_events/di.dart';
import 'package:omsk_events/model/event-short.dart';
import 'package:omsk_events/resources/providers/timetable-api-provider.dart';
import 'package:omsk_events/resources/repositories/abstract/timetable-repository.dart';

class ApiTimetableRepository implements TimetableRepository {
  final _api = TimetableAPIProvider(tokenProvider: DI.tokenProvider);

  @override
  Future<List<EventShort>> fetchTimetable() async {
    return _api.getLikedEvents();
  }
}