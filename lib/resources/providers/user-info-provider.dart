class UserInfo {
  final int vkId;
  final String token;

  UserInfo(this.vkId, this.token);

  UserInfo.fromJson(Map<String, dynamic> parsedJson)
      : vkId = parsedJson["vkId"], token = parsedJson["token"];

  dynamic toJson() => {'vkId': vkId, 'token': token};
}

abstract class UserInfoProvider {
  Future<void> setUserInfo(UserInfo info);
  Future<UserInfo> getUserInfo();
  Future<bool> isBanned();
}
