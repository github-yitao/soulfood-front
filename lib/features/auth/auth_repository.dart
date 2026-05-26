import 'package:soulfood_front/core/api/api_client.dart';
import 'package:soulfood_front/core/config/app_config.dart';
import 'package:soulfood_front/core/session/session_store.dart';

class UserProfile {
  UserProfile({
    required this.userId,
    required this.nickname,
    this.username,
    this.avatarUrl,
    this.signature,
    this.phone,
    this.inviteBadgeUnlocked = false,
  });

  final int userId;
  final String nickname;
  final String? username;
  final String? avatarUrl;
  final String? signature;
  final String? phone;
  final bool inviteBadgeUnlocked;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: (json['userId'] as num).toInt(),
      nickname: json['nickname'] as String? ?? '用户',
      username: json['username'] as String?,
      avatarUrl: _resolveMediaUrl(json['avatarUrl'] as String?),
      signature: json['signature'] as String?,
      phone: json['phone'] as String?,
      inviteBadgeUnlocked: json['inviteBadgeUnlocked'] as bool? ?? false,
    );
  }
}

String? _resolveMediaUrl(String? path) {
  if (path == null || path.isEmpty) return path;
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  final base = AppConfig.baseUrl;
  if (path.startsWith('/')) return '$base$path';
  return '$base/$path';
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

  Future<UserProfile> bindPhone(String phone) async {
    return _api.patchData(
      '/api/v1/auth/me/phone',
      data: {'phone': phone},
      parser: (json) => UserProfile.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<UserProfile> uploadAvatar(String filePath) async {
    return _api.postMultipart(
      '/api/v1/auth/me/avatar',
      filePath: filePath,
      fieldName: 'file',
      parser: (json) => UserProfile.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _api.postVoid(
      '/api/v1/auth/me/password',
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<void> resetPassword({
    required String username,
    required String phone,
    required String newPassword,
  }) async {
    await _api.postVoid(
      '/api/v1/auth/password/reset',
      data: {
        'username': username,
        'phone': phone,
        'newPassword': newPassword,
      },
      skipAuthRecovery: true,
    );
  }

  Future<void> _saveFromResponse(Map<String, dynamic> data, {String? username}) async {
    final userId = (data['userId'] as num).toInt();
    final nickname = data['nickname'] as String? ?? username ?? '用户';
    final token = data['token'] as String? ?? '';
    final refresh = data['refreshToken'] as String? ?? '';
    if (token.isEmpty) {
      throw ApiException('登录响应缺少 token');
    }
    await _session.saveUser(
      userId: userId,
      nickname: nickname,
      accessToken: token,
      refreshToken: refresh.isEmpty ? null : refresh,
      username: username,
    );
  }
}
