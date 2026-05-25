import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  static const _keyDeviceId = 'device_id';
  static const _keyUserId = 'user_id';
  static const _keyUsername = 'username';
  static const _keyNickname = 'nickname';

  int? userId;
  String? username;
  String? nickname;

  bool get isLoggedIn => userId != null;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt(_keyUserId);
    username = prefs.getString(_keyUsername);
    nickname = prefs.getString(_keyNickname);
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
    String? username,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    this.userId = userId;
    this.nickname = nickname;
    this.username = username;
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyNickname, nickname);
    if (username != null) {
      await prefs.setString(_keyUsername, username);
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    userId = null;
    username = null;
    nickname = null;
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyNickname);
  }
}
