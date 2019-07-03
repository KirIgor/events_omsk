import 'package:http/http.dart' show Client;
import 'dart:async';
import 'dart:convert';

import 'api-prodiver.dart';

class LoginAPIProvider extends APIProvider {
  Client _client = Client();

  Future<String> login(String vkAuthToken) async {
    final response = await _client.post("$baseURL/login",
        body: json.encode({"accessToken": vkAuthToken}));

    if (response.statusCode == 200) {
      return response.headers["authorization"];
    } else
      throw Exception(response.body);
  }
}
