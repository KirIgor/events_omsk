import 'dart:convert';

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:omsk_events/model/event-short.dart';
import 'package:omsk_events/resources/providers/api-prodiver.dart';
import 'package:omsk_events/resources/providers/token-provider.dart';

class TimetableAPIProvider extends APIProvider {
  final Client _client = Client();
  final TokenProvider _tokenProvider;

  TimetableAPIProvider({@required TokenProvider tokenProvider}): _tokenProvider = tokenProvider;

  Future<List<EventShort>> getLikedEvents() async {
    final token = await _tokenProvider.getToken();
    if (token == null) throw NotAuthorizedException();

    final response =
    await _client.get("$baseURL/events/liked", headers: Map<String, String>()
      ..putIfAbsent("Authorization", () => token));
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((e) => EventShort.fromJson(e))
          .toList();
    } else
      throw Exception(response.body);
  }

}