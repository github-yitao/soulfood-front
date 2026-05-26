import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  static const _keyDeviceId = 'device_id';
  static const _keyUserId = 'user_id';
  static const _keyUsername = 'username';
  static const _keyNickname = 'nickname';
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';

  int? userId;
  String? username;
  String? nickname;
  String? accessToken;
  String? refreshToken;

  bool get isLoggedIn => accessToken != null && accessToken!.isNotEmpty;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt(_keyUserId);
    username = prefs.getString(_keyUsername);
    nickname = prefs.getString(_keyNickname);
    accessToken = prefs.getString(_keyAccessToken);
    refreshToken = prefs.getString(_keyRefreshToken);
  }

  Future<String> deviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_keyDeviceId);
    if (id == null || id.isEmpty) {
      id = 'dev-${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(_keyDeviceId, id);
    }
    return id;
  }

  Future<void> saveUser({
    required int userId,
    required String nickname,
    required String accessToken,
    String? refreshToken,
    String? username,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    this.userId = userId;
    this.nickname = nickname;
    this.username = username;
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyNickname, nickname);
    await prefs.setString(_keyAccessToken, accessToken);
    if (refreshToken != null) {
      await prefs.setString(_keyRefreshToken, refreshToken);
    }
    if (username != null) {
      await prefs.setString(_keyUsername, username);
    }
  }

  Future<void> updateTokens({required String accessToken, required String refreshToken}) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
  }

  Future<void> updateNickname(String nickname) async {
    this.nickname = nickname;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNickname, nickname);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    userId = null;
    username = null;
    nickname = null;
    accessToken = null;
    refreshToken = null;
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyNickname);
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
  }
}
