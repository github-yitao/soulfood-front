import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 房间号展示 + 复制 + 好友加入说明
class RoomInviteCard extends StatelessWidget {
  const RoomInviteCard({
    super.key,
    required this.roomCode,
    this.compact = false,
  });

  final String roomCode;
  final bool compact;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: roomCode));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('房间号 $roomCode 已复制')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 14 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD4B8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '邀请好友投票',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          if (!compact) ...[
            const SizedBox(height: 6),
            const Text(
              '把房间号发给好友，对方可通过以下方式进入：',
              style: TextStyle(fontSize: 12, color: Color(0xFF6F7888), height: 1.4),
            ),
            const SizedBox(height: 4),
            const Text(
              '① 首页 → 和朋友一起决定 → 加入房间\n'
              '② 首页 → 和朋友一起决定 → 好友的房间（需先加好友）',
              style: TextStyle(fontSize: 12, color: Color(0xFF6F7888), height: 1.5),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('房间号', style: TextStyle(fontSize: 12, color: Color(0xFF6F7888))),
                    const SizedBox(height: 4),
                    Text(
                      roomCode,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                        color: Color(0xFFD86A00),
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => _copy(context),
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF8A43)),
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('复制'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> showRoomCreatedDialog(BuildContext context, String roomCode) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('房间创建成功'),
      content: SingleChildScrollView(
        child: RoomInviteCard(roomCode: roomCode),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF8A43)),
          child: const Text('开始投票'),
        ),
      ],
    ),
  );
}
