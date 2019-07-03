import 'package:meta/meta.dart';
import 'package:omsk_events/model/album-short.dart';
import 'package:omsk_events/model/album.dart';
import 'package:omsk_events/resources/repositories/abstract/album-repository.dart';
import 'package:omsk_events/resources/repositories/abstract/event-repository.dart';
import 'package:rxdart/rxdart.dart';

import 'bloc-base.dart';

class GalleryBloc extends BlocBase {
  final int _eventId;
  final EventRepository _eventRepository;
  final AlbumRepository _albumRepository;

  final _albumsFetcher = PublishSubject<List<AlbumShort>>();
  Observable<List<AlbumShort>> get albums => _albumsFetcher.stream;

  final _fullAlbumFetcher = PublishSubject<Album>();
  Observable<Album> get fullAlbum => _fullAlbumFetcher.stream;

  GalleryBloc(
      {int eventId,
      @required EventRepository eventRepository,
      @required AlbumRepository albumRepository})
      : _eventId = eventId,
        _eventRepository = eventRepository,
        _albumRepository = albumRepository;

  @override
  void dispose() {
    _albumsFetcher.close();
    _fullAlbumFetcher.close();
  }

  Future<void> loadAlbums() async {
    assert(_eventId != null);

    final albums = await _eventRepository.fetchEventAlbums(_eventId);
    _albumsFetcher.add(albums);
  }

  Future<void> loadAlbumById(int id) async {
    final album = await _albumRepository.fetchAlbum(id);
    _fullAlbumFetcher.add(album);
  }
}
