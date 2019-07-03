import 'package:omsk_events/model/album-short.dart';
import 'package:omsk_events/model/event-short.dart';
import 'package:omsk_events/model/event.dart';
import 'package:omsk_events/model/success.dart';
import 'package:omsk_events/resources/repositories/abstract/event-repository.dart';
import 'package:omsk_events/resources/repositories/abstract/timetable-repository.dart';

class CacheRepository implements TimetableRepository, EventRepository {

  @override
  Future<Success> dislikeEvent(int id) {
    // TODO: implement dislikeEvent
    return null;
  }

  @override
  Future<EventFull> fetchEvent(int id) {
    // TODO: implement fetchEvent
    return null;
  }

  @override
  Future<List<AlbumShort>> fetchEventAlbums(int id) {
    // TODO: implement fetchEventAlbums
    return null;
  }

  @override
  Future<List<EventShort>> fetchEvents(
      {int page = 0,
      int pageSize = 10,
      OrderBy orderBy = OrderBy.LIKES_COUNT,
      OrderType orderType = OrderType.DESC}) {
    // TODO: implement fetchEvents
    return null;
  }

  @override
  Future<List<EventShort>> fetchTimetable() {
    // TODO: implement fetchTimetable
    return null;
  }

  @override
  Future<Success> likeEvent(int id) {
    // TODO: implement likeEvent
    return null;
  }
}
