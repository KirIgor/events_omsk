import 'package:omsk_events/model/album-short.dart';
import 'package:omsk_events/model/event-short.dart';
import 'package:omsk_events/model/event.dart';
import 'package:omsk_events/model/success.dart';

abstract class EventRepository {
  Future<List<EventShort>> fetchEvents(
      {int page = 0,
      int pageSize = 10,
      OrderBy orderBy = OrderBy.likesCount,
      OrderType orderType = OrderType.DESC,
      Map<String, dynamic> filter, bool followSettings = true});

  Future<EventFull> fetchEvent(int id);

  Future<List<AlbumShort>> fetchEventAlbums(int id);

  Future<Success> likeEvent(int id);

  Future<Success> dislikeEvent(int id);
}
