import 'package:soulfood_front/core/api/api_client.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';
import 'package:soulfood_front/features/friend_chat/friend_chat_models.dart';

class FriendChatRepository {
  FriendChatRepository() : _api = AppServices.I.api;

  final ApiClient _api;

  Future<List<FriendChatConversation>> listConversations() async {
    final data = await _api.getData<List<dynamic>>(
      '/api/v1/friends/chat/conversations',
      parser: (json) => json as List<dynamic>,
    );
    return data.map((e) => FriendChatConversation.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<FriendChatConversation> openConversation(int friendUserId) async {
    final data = await _api.postData<Map<String, dynamic>>(
      '/api/v1/friends/chat/conversations/$friendUserId',
      parser: (json) => json as Map<String, dynamic>,
    );
    return FriendChatConversation.fromJson(data);
  }

  Future<List<FriendChatMessage>> listMessages({
    required int conversationId,
    int? beforeId,
    int limit = 50,
  }) async {
    final query = <String, dynamic>{'limit': limit};
    if (beforeId != null) {
      query['beforeId'] = beforeId;
    }
    final data = await _api.getData<List<dynamic>>(
      '/api/v1/friends/chat/conversations/$conversationId/messages',
      query: query,
      parser: (json) => json as List<dynamic>,
    );
    return data.map((e) => FriendChatMessage.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<FriendChatMessage> sendMessage({
    required int conversationId,
    required String content,
  }) async {
    final data = await _api.postData<Map<String, dynamic>>(
      '/api/v1/friends/chat/conversations/$conversationId/messages',
      data: {'content': content},
      parser: (json) => json as Map<String, dynamic>,
    );
    return FriendChatMessage.fromJson(data);
  }

  Future<void> markRead(int conversationId) async {
    await _api.postVoid('/api/v1/friends/chat/conversations/$conversationId/read');
  }
}
