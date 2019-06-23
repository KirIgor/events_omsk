import 'package:meta/meta.dart';
import 'package:omsk_events/model/album-short.dart';
import 'package:omsk_events/model/album.dart';
import 'package:omsk_events/model/event-short.dart';

import 'package:omsk_events/model/event.dart';

import 'package:omsk_events/model/success.dart';

import 'abstract/event-repository.dart';

class ApiCacheMediator implements EventRepository {
  final EventRepository _cacheRepository;
  final EventRepository _apiRepository;

  ApiCacheMediator(
      {@required EventRepository cache, @required EventRepository api})
      : _cacheRepository = cache,
        _apiRepository = api;

  @override
  Future<Success> dislikeEvent(int id) => _apiRepository.dislikeEvent(id);

  @override
  Future<Success> likeEvent(int id) => _apiRepository.likeEvent(id);

  @override
  Future<EventFull> fetchEvent(int id) {
    return _apiRepository.fetchEvent(id);
  }

  @override
  Future<List<AlbumShort>> fetchEventAlbums(int id) {
    return _apiRepository.fetchEventAlbums(id);
  }

  @override
  Future<List<EventShort>> fetchEvents(
      {int page = 0,
      int pageSize = 10,
      OrderBy orderBy = OrderBy.LIKES_COUNT,
      OrderType orderType = OrderType.DESC}) {
    return _apiRepository.fetchEvents(
        page: page, pageSize: pageSize, orderBy: orderBy, orderType: orderType);
  }
}
