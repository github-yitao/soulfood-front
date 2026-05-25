import 'package:soulfood_front/core/api/api_client.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';

class FriendItem {
  FriendItem({
    required this.userId,
    required this.nickname,
    required this.avatarUrl,
    required this.source,
    required this.addedAt,
  });

  final int userId;
  final String nickname;
  final String? avatarUrl;
  final String source;
  final String addedAt;

  String get sourceLabel => source == 'invite' ? '邀请注册' : '主动添加';

  factory FriendItem.fromJson(Map<String, dynamic> json) {
    return FriendItem(
      userId: (json['userId'] as num).toInt(),
      nickname: json['nickname'] as String? ?? '好友',
      avatarUrl: json['avatarUrl'] as String?,
      source: json['source'] as String? ?? 'manual',
      addedAt: json['addedAt'] as String? ?? '',
    );
  }
}

class FriendRepository {
  FriendRepository() : _api = AppServices.I.api;

  final ApiClient _api;

  Future<List<FriendItem>> listFriends() async {
    final data = await _api.getData<List<dynamic>>(
      '/api/v1/friends',
      parser: (json) => json as List<dynamic>,
    );
    return data.map((e) => FriendItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<FriendItem> addFriend(String inviteCode) async {
    final data = await _api.postData<Map<String, dynamic>>(
      '/api/v1/friends',
      data: {'inviteCode': inviteCode.trim()},
      parser: (json) => json as Map<String, dynamic>,
    );
    return FriendItem.fromJson(data);
  }
}
