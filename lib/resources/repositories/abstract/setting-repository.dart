import 'package:omsk_events/model/setting.dart';

abstract class SettingRepository {
  Future<List<Setting>> fetchSettings(
      {int page = 0,
      int pageSize = 10,
      OrderBy orderBy = OrderBy.id,
      OrderType orderType = OrderType.ASC});
}
