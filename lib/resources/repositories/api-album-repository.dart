import 'package:omsk_events/model/album.dart';
import 'package:omsk_events/resources/providers/album-api-provider.dart';
import 'package:omsk_events/resources/repositories/abstract/album-repository.dart';

class ApiAlbumRepository implements AlbumRepository {
  final _api = AlbumAPIProvider();

  @override
  Future<Album> fetchAlbum(int albumId) {
    return _api.fetchAlbum(albumId);
  }
}