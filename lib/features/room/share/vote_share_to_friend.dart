import 'package:flutter/material.dart';
import 'package:soulfood_front/core/api/api_client.dart';
import 'package:soulfood_front/features/friend/friend_picker_sheet.dart';
import 'package:soulfood_front/features/friend_chat/friend_chat_page.dart';
import 'package:soulfood_front/features/friend_chat/friend_chat_repository.dart';
import 'package:soulfood_front/features/room/share/vote_share_data.dart';
import 'package:soulfood_front/features/room/share/vote_share_payload.dart';
import 'package:soulfood_front/routing/app_routes.dart';

/// 将投票分享卡发送给好友并进入聊天页。
class VoteShareToFriend {
  VoteShareToFriend._();

  static Future<void> send(BuildContext context, VoteShareData data) async {
    final friend = await FriendPickerSheet.pick(context);
    if (friend == null || !context.mounted) return;

    final chatRepo = FriendChatRepository();
    try {
      final conversation = await chatRepo.openConversation(friend.userId);
      final payload = VoteSharePayload.fromVoteShareData(data);
      await chatRepo.sendVoteShare(
        conversationId: conversation.conversationId,
        payload: payload,
      );
      if (!context.mounted) return;

      Navigator.pop(context);
      await Navigator.pushNamed(
        context,
        AppRoutes.friendChat,
        arguments: FriendChatArgs(
          friendUserId: friend.userId,
          nickname: friend.nickname,
          avatarUrl: friend.avatarUrl,
        ),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已发送给 ${friend.nickname}')),
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}
