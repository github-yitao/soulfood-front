/// 组局入房链接：用于二维码与深链接解析。
class RoomJoinLink {
  RoomJoinLink._();

  static String build(String roomCode) {
    final code = roomCode.trim().toUpperCase();
    return 'decidemeal://join?code=$code';
  }

  static String shareMessage(String roomCode) {
    final code = roomCode.trim().toUpperCase();
    final link = build(code);
    return '来 DecideMeal 一起投票选餐厅！\n房间号：$code\n打开链接或扫码入房：$link';
  }

  /// 从二维码/深链接/纯 6 位数字解析房间号。
  static String? parseRoomCode(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;

    if (RegExp(r'^\d{6}$').hasMatch(text)) {
      return text;
    }

    final uri = Uri.tryParse(text);
    if (uri == null) return null;

    if (uri.scheme == 'decidemeal' && uri.host == 'join') {
      final fromQuery = uri.queryParameters['code'];
      if (fromQuery != null && RegExp(r'^\d{6}$').hasMatch(fromQuery.trim())) {
        return fromQuery.trim();
      }
      if (uri.pathSegments.isNotEmpty) {
        final fromPath = uri.pathSegments.last;
        if (RegExp(r'^\d{6}$').hasMatch(fromPath)) {
          return fromPath;
        }
      }
    }

    final segments = uri.pathSegments;
    if (segments.length >= 2 && segments[segments.length - 2] == 'join') {
      final code = segments.last;
      if (RegExp(r'^\d{6}$').hasMatch(code)) {
        return code;
      }
    }

    return null;
  }
}
