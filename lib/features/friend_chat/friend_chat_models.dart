import 'package:soulfood_front/features/room/share/vote_share_payload.dart';

class FriendChatConversation {
  FriendChatConversation({
    required this.conversationId,
    required this.peerUserId,
    required this.peerNickname,
    required this.peerAvatarUrl,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  final int conversationId;
  final int peerUserId;
  final String peerNickname;
  final String? peerAvatarUrl;
  final String lastMessage;
  final String lastMessageAt;
  final int unreadCount;

  factory FriendChatConversation.fromJson(Map<String, dynamic> json) {
    return FriendChatConversation(
      conversationId: (json['conversationId'] as num).toInt(),
      peerUserId: (json['peerUserId'] as num).toInt(),
      peerNickname: json['peerNickname'] as String? ?? '好友',
      peerAvatarUrl: json['peerAvatarUrl'] as String?,
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageAt: json['lastMessageAt'] as String? ?? '',
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class FriendChatMessage {
  FriendChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.messageType,
    required this.content,
    required this.createdAt,
    required this.mine,
    this.voteShare,
  });

  final int id;
  final int conversationId;
  final int senderId;
  final String messageType;
  final String content;
  final String createdAt;
  final bool mine;
  final VoteSharePayload? voteShare;

  bool get isVoteShare => messageType == 'vote_share' && voteShare != null;

  factory FriendChatMessage.fromJson(Map<String, dynamic> json) {
    final type = json['messageType'] as String? ?? 'text';
    VoteSharePayload? payload;
    final rawPayload = json['voteShare'];
    if (rawPayload is Map<String, dynamic>) {
      payload = VoteSharePayload.fromJson(rawPayload);
    }
    return FriendChatMessage(
      id: (json['id'] as num).toInt(),
      conversationId: (json['conversationId'] as num).toInt(),
      senderId: (json['senderId'] as num).toInt(),
      messageType: type,
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      mine: json['mine'] as bool? ?? false,
      voteShare: payload,
    );
  }
}
