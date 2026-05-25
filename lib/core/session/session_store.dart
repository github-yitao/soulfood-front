import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  static const _keyDeviceId = 'device_id';
  static const _keyUserId = 'user_id';
  static const _keyNickname = 'nickname';

  int? userId;
  String? nickname;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt(_keyUserId);
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

  Future<void> saveUser({required int userId, required String nickname}) async {
    final prefs = await SharedPreferences.getInstance();
    this.userId = userId;
    this.nickname = nickname;
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyNickname, nickname);
  }
}
