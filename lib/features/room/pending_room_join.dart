import 'package:soulfood_front/features/room/room_join_link.dart';

/// 冷启动深链接暂存的房间号（登录后消费）。
class PendingRoomJoin {
  PendingRoomJoin._();

  static String? _code;

  static void set(String? code) {
    _code = code == null ? null : RoomJoinLink.parseRoomCode(code) ?? code.trim().toUpperCase();
  }

  static String? take() {
    final code = _code;
    _code = null;
    return code;
  }
}
