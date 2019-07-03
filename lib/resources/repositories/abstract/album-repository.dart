import 'package:omsk_events/model/album.dart';

abstract class AlbumRepository {
  Future<Album> fetchAlbum(int albumId);
}