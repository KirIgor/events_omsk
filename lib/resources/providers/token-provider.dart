class NotAuthorizedException implements Exception {}

abstract class TokenProvider {
  Future<void> setToken(String token);
  Future<String> getToken();
}