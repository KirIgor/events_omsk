import 'package:http/http.dart' show Client;
import 'dart:async';
import 'dart:convert';

import 'package:omsk_events/model/album.dart';
import 'api-prodiver.dart';

class AlbumAPIProvider extends APIProvider {
  Client _client = Client();

  Future<Album> fetchAlbum(int id) async {
    final response = await _client.get("$baseURL/albums/$id");

    if (response.statusCode == 200) {
      return Album.fromJson(json.decode(response.body));
    } else
      throw Exception(response.body);
  }
}
