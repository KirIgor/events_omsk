import 'package:http/http.dart' show Client;
import 'package:meta/meta.dart';
import 'package:omsk_events/model/comment.dart';
import 'package:omsk_events/resources/providers/token-provider.dart';
import 'dart:async';
import 'dart:convert';

import 'api-prodiver.dart';

class CommentAPIProvider extends APIProvider {
  final Client _client = Client();
  final TokenProvider _tokenProvider;

  CommentAPIProvider({@required TokenProvider tokenProvider}):
      _tokenProvider = tokenProvider;

  Future<List<Comment>> fetchComments(
      {int eventId, int pageSize = 10, int page = 0}) async {
    final response = await _client
        .get("$baseURL/events/$eventId/comments?pageSize=$pageSize&page=$page");

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((c) => Comment.fromJson(c))
          .toList();
    } else
      throw Exception(response.body);
  }

  Future<Comment> createComment({int eventId, String text}) async {
    final token = await _tokenProvider.getToken();
    if (token == null) throw NotAuthorizedException();
    final response = await _client.post("$baseURL/events/$eventId/comments",
        body: json.encode({"text": text}),
        headers: Map<String, String>()
          ..putIfAbsent("Authorization", () => token)
          ..putIfAbsent("Content-type", () => "application/json"));

    if (response.statusCode == 200) {
      return Comment.fromJson(json.decode(response.body));
    } else
      throw Exception(response.body);
  }

  Future<void> editComment({int commentId, String text}) async {
    final token = await _tokenProvider.getToken();
    if (token == null) throw NotAuthorizedException();
    final response = await _client.patch("$baseURL/comments/$commentId",
        body: {"text": text},
        headers: Map<String, String>()
          ..putIfAbsent("Authorization", () => token));

    if (response.statusCode != 204) throw Exception(response.body);
  }

  Future<void> deleteComment({int commentId}) async {
    final token = await _tokenProvider.getToken();
    if (token == null) throw NotAuthorizedException();
    final response = await _client.delete("$baseURL/comments/$commentId",
        headers: Map<String, String>()
          ..putIfAbsent("Authorization", () => token));

    if (response.statusCode != 204) throw Exception(response.body);
  }
}
