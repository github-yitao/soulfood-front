import 'package:soulfood_front/core/api/api_client.dart';
import 'package:soulfood_front/core/session/session_store.dart';

class LoginResult {
  LoginResult({
    required this.userId,
    required this.nickname,
    this.username,
  });

  final int userId;
  final String nickname;
  final String? username;
}

class UserProfile {
  UserProfile({
    required this.userId,
    required this.nickname,
    this.username,
    this.avatarUrl,
    this.signature,
  });

  final int userId;
  final String nickname;
  final String? username;
  final String? avatarUrl;
  final String? signature;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: (json['userId'] as num).toInt(),
      nickname: json['nickname'] as String? ?? '用户',
      username: json['username'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      signature: json['signature'] as String?,
    );
  }
}

class AuthRepository {
  AuthRepository(this._api, this._session);

  final ApiClient _api;
  final SessionStore _session;

  bool get isLoggedIn => _session.isLoggedIn;

  Future<void> login({
    required String username,
    required String password,
  }) async {
    final data = await _api.postData<Map<String, dynamic>>(
      '/api/v1/auth/login',
      data: {'username': username, 'password': password},
      parser: (json) => json as Map<String, dynamic>,
    );
    await _saveFromResponse(data, username: username.trim());
  }

  Future<void> register({
    required String username,
    required String password,
    String? nickname,
    String? inviteCode,
  }) async {
    final data = await _api.postData<Map<String, dynamic>>(
      '/api/v1/auth/register',
      data: {
        'username': username,
        'password': password,
        if (nickname != null && nickname.isNotEmpty) 'nickname': nickname,
        if (inviteCode != null && inviteCode.isNotEmpty) 'inviteCode': inviteCode,
      },
      parser: (json) => json as Map<String, dynamic>,
    );
    await _saveFromResponse(data, username: username.trim());
  }

  Future<void> logout() async {
    await _session.clear();
  }

  Future<UserProfile> getProfile() async {
    return _api.getData(
      '/api/v1/auth/me',
      parser: (json) => UserProfile.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<UserProfile> updateProfile({
    String? nickname,
    String? avatarUrl,
    String? signature,
  }) async {
    final data = <String, dynamic>{};
    if (nickname != null) data['nickname'] = nickname;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
    if (signature != null) data['signature'] = signature;

    final profile = await _api.patchData<UserProfile>(
      '/api/v1/auth/me',
      data: data,
      parser: (json) => UserProfile.fromJson(json as Map<String, dynamic>),
    );
    await _session.updateNickname(profile.nickname);
    return profile;
  }

  Future<void> _saveFromResponse(Map<String, dynamic> data, {String? username}) async {
    final userId = (data['userId'] as num).toInt();
    final nickname = data['nickname'] as String? ?? username ?? '用户';
    final token = data['token'] as String? ?? '';
    if (token.isEmpty) {
      throw ApiException('登录响应缺少 token');
    }
    await _session.saveUser(
      userId: userId,
      nickname: nickname,
      accessToken: token,
      username: username,
    );
  }
}
