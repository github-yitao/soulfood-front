import 'package:flutter/material.dart';
import 'package:soulfood_front/core/storage/recent_rooms_store.dart';
import 'package:soulfood_front/features/room/room_join_link.dart';
import 'package:soulfood_front/features/room/room_repository.dart';
import 'package:soulfood_front/routing/app_routes.dart';

Future<bool> joinRoomAndNavigate(BuildContext context, String rawCode) async {
  final code = RoomJoinLink.parseRoomCode(rawCode) ?? rawCode.trim().toUpperCase();
  if (!RegExp(r'^\d{6}$').hasMatch(code)) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无效的房间号，请扫描 DecideMeal 房间二维码')),
      );
    }
    return false;
  }

  try {
    await RoomRepository().joinRoom(code);
    await RecentRoomsStore().remember(code);
    if (!context.mounted) return false;
    Navigator.pushReplacementNamed(context, AppRoutes.vote, arguments: code);
    return true;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
    return false;
  }
}
