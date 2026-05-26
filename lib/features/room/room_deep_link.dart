import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:soulfood_front/features/room/pending_room_join.dart';
import 'package:soulfood_front/features/room/room_join_flow.dart';
import 'package:soulfood_front/features/room/room_join_link.dart';
import 'package:soulfood_front/routing/app_routes.dart';

/// 监听 `decidemeal://join?code=xxxxxx` 深链接。
class RoomDeepLinkListener {
  RoomDeepLinkListener._();

  static final _appLinks = AppLinks();

  static Future<void> captureInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        PendingRoomJoin.set(RoomJoinLink.parseRoomCode(uri.toString()));
      }
    } catch (_) {
      // ignore
    }
  }

  static void listenWhileMounted(BuildContext context) {
    _appLinks.uriLinkStream.listen((uri) async {
      final code = RoomJoinLink.parseRoomCode(uri.toString());
      if (code == null || !context.mounted) return;
      await joinRoomAndNavigate(context, code);
    });
  }

  static Future<bool> tryConsumePendingJoin(BuildContext context) async {
    final code = PendingRoomJoin.take();
    if (code == null || !context.mounted) return false;
    return joinRoomAndNavigate(context, code);
  }

  static Future<void> openScan(BuildContext context) {
    return Navigator.pushNamed(context, AppRoutes.scanJoinRoom);
  }
}
