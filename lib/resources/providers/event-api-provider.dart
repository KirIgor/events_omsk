import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' show Client, Response;
import 'package:meta/meta.dart';
import 'package:omsk_events/model/album-short.dart';
import 'package:omsk_events/model/event-short.dart';
import 'package:omsk_events/model/event.dart';
import 'package:omsk_events/model/success.dart';
import 'package:omsk_events/resources/providers/token-provider.dart';

import 'api-prodiver.dart';

class EventAPIProvider extends APIProvider {
  final Client _client = Client();
  final TokenProvider _tokenProvider;

  EventAPIProvider({@required TokenProvider tokenProvider})
      : _tokenProvider = tokenProvider;

  Future<List<EventShort>> fetchEvents(
      {int page = 0,
      int pageSize = 10,
      OrderBy orderBy = OrderBy.LIKES_COUNT,
      OrderType orderType = OrderType.DESC}) async {
    final orderByText = orderBy.toString().split(".")[1];
    final orderTypeText = orderType.toString().split(".")[1];

    final response = await _client.get(
        "$baseURL/events?pageSize=$pageSize&page=$page&orderBy=$orderByText&orderType=$orderTypeText");

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((e) => EventShort.fromJson(e))
          .toList();
    } else
      throw Exception(response.body);
  }

  Future<EventFull> fetchEvent(int id) async {
    final token = await _tokenProvider.getToken();
    Response response;
    if (token != null) {
      response = await _client.get("$baseURL/events/$id",
          headers: Map<String, String>()
            ..putIfAbsent("Authorization", () => token));
    } else {
      response = await _client.get("$baseURL/events/$id");
    }

    if (response.statusCode == 200) {
      return EventFull.fromJson(json.decode(response.body));
    } else
      throw Exception(response.body);
  }

  Future<List<AlbumShort>> fetchEventAlbums(int id) async {
    final response = await _client.get("$baseURL/events/$id/albums");

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((a) => AlbumShort.fromJson(a))
          .toList();
    } else
      throw Exception(response.body);
  }

  Future<Success> likeEvent(int id) async {
    final token = await _tokenProvider.getToken();
    if (token == null) throw NotAuthorizedException();
    final response = await _client.put("$baseURL/events/$id/like",
        headers: Map<String, String>()
          ..putIfAbsent("Authorization", () => token));

    if (response.statusCode == 200) {
      return Success.fromJson(json.decode(response.body));
    } else
      throw Exception(response.body);
  }

  Future<Success> dislikeEvent(int id) async {
    final token = await _tokenProvider.getToken();
    if (token == null) throw NotAuthorizedException();
    final response = await _client.put("$baseURL/events/$id/dislike",
        headers: Map<String, String>()
          ..putIfAbsent("Authorization", () => token));

    if (response.statusCode == 200) {
      return Success.fromJson(json.decode(response.body));
    } else
      throw Exception(response.body);
  }
}
