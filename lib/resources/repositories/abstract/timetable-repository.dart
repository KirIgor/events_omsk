import 'package:omsk_events/model/event-short.dart';
import 'package:omsk_events/model/event.dart';

abstract class TimetableRepository {
  Future<List<EventShort>> fetchTimetable();
}
