import 'package:soulfood_front/core/api/api_client.dart';
import 'package:soulfood_front/core/session/session_store.dart';

class LoginResult {
  LoginResult({required this.userId, required this.nickname});

  final int userId;
  final String nickname;
}

class UserProfile {
  UserProfile({
    required this.userId,
    required this.nickname,
    this.avatarUrl,
    this.signature,
  });

  final int userId;
  final String nickname;
  final String? avatarUrl;
  final String? signature;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: (json['userId'] as num).toInt(),
      nickname: json['nickname'] as String? ?? '用户',
      avatarUrl: json['avatarUrl'] as String?,
      signature: json['signature'] as String?,
    );
  }
}

class AuthRepository {
  AuthRepository(this._api, this._session);

  final ApiClient _api;
  final SessionStore _session;

  Future<LoginResult> ensureLoggedIn() async {
    if (_session.userId != null) {
      return LoginResult(userId: _session.userId!, nickname: _session.nickname ?? '用户');
    }
    return mockLogin();
  }

  Future<LoginResult> mockLogin() async {
    final deviceId = await _session.deviceId();
    final data = await _api.postData<Map<String, dynamic>>(
      '/api/v1/auth/login/mock',
      data: {'deviceId': deviceId},
      parser: (json) => json as Map<String, dynamic>,
    );
    final userId = (data['userId'] as num).toInt();
    final nickname = data['nickname'] as String? ?? '用户';
    await _session.saveUser(userId: userId, nickname: nickname);
    return LoginResult(userId: userId, nickname: nickname);
  }

  Future<UserProfile> getProfile() async {
    return _api.getData(
      '/api/v1/auth/me',
      parser: (json) => UserProfile.fromJson(json as Map<String, dynamic>),
    );
  }
}
