class UserInfo {
  final int vkId;

  UserInfo(this.vkId);

  UserInfo.fromJson(Map<String, dynamic> parsedJson)
      : vkId = parsedJson["vkId"];

  dynamic toJson() => {'vkId': vkId};
}

abstract class UserInfoProvider {
  Future<void> setUserInfo(UserInfo info);
  Future<UserInfo> getUserInfo();
}
