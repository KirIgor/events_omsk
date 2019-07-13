import 'package:omsk_events/model/setting.dart';
import 'package:omsk_events/resources/providers/setting-api-provider.dart';
import 'package:omsk_events/resources/repositories/abstract/setting-repository.dart';

class ApiSettingRepository implements SettingRepository {
  final settingProvider = SettingAPIProvider();

  @override
  Future<List<Setting>> fetchSettings(
      {int page = 0,
      int pageSize = 10,
      SettingsOrderBy orderBy = SettingsOrderBy.id,
      SettingsOrderType orderType = SettingsOrderType.ASC}) {
    return settingProvider.fetchSettings(
        page: page, pageSize: pageSize, orderBy: orderBy, orderType: orderType);
  }
}
