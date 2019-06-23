import 'package:omsk_events/di.dart';
import 'package:omsk_events/model/album-short.dart';
import 'package:omsk_events/model/album.dart';
import 'package:omsk_events/model/event-short.dart';
import 'package:omsk_events/model/event.dart';
import 'package:omsk_events/model/success.dart';
import 'package:omsk_events/resources/providers/event-api-provider.dart';
import 'package:omsk_events/resources/repositories/abstract/event-repository.dart';

class ApiEventRepository implements EventRepository {
  final eventsProvider = EventAPIProvider(tokenProvider: DI.tokenProvider);

  @override
  Future<List<EventShort>> fetchEvents(
      {int page = 0,
      int pageSize = 10,
      OrderBy orderBy = OrderBy.LIKES_COUNT,
      OrderType orderType = OrderType.DESC}) {
    return eventsProvider.fetchEvents(
        page: page, pageSize: pageSize, orderBy: orderBy, orderType: orderType
    );
  }

  @override
  Future<EventFull> fetchEvent(int id) => eventsProvider.fetchEvent(id);

  @override
  Future<List<AlbumShort>> fetchEventAlbums(int id) =>
      eventsProvider.fetchEventAlbums(id);

  @override
  Future<Success> likeEvent(int id) => eventsProvider.likeEvent(id);

  @override
  Future<Success> dislikeEvent(int id) => eventsProvider.dislikeEvent(id);
}
