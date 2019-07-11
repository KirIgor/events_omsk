import 'package:http/http.dart' show Client;
import 'dart:async';
import 'dart:convert';

import 'package:omsk_events/model/setting.dart';
import 'api-prodiver.dart';

class SettingAPIProvider extends APIProvider {
  Client _client = Client();

  Future<List<Setting>> fetchSettings(
      {int page = 0,
        int pageSize = 10,
        OrderBy orderBy = OrderBy.id,
        OrderType orderType = OrderType.ASC
      }) async {
    final orderByText = orderBy.toString().split(".")[1];
    final orderTypeText = orderType.toString().split(".")[1];

    final response = await _client.get("$baseURL/events?pageSize=$pageSize&page=$page&orderBy=$orderByText&orderType=$orderTypeText");

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((e) => Setting.fromJson(e))
          .toList();
    } else
      throw Exception(response.body);
  }
}
