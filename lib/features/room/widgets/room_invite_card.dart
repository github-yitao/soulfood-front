import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/core/theme/theme_widgets.dart';
import 'package:soulfood_front/features/room/room_join_link.dart';

/// 房间号展示 + 二维码 + 复制 + 好友加入说明
class RoomInviteCard extends StatelessWidget {
  const RoomInviteCard({
    super.key,
    required this.roomCode,
    this.compact = false,
    this.showQr,
  });

  final String roomCode;
  final bool compact;
  final bool? showQr;

  bool get _showQr => showQr ?? !compact;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: roomCode));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('房间号 $roomCode 已复制')),
      );
    }
  }

  Future<void> _share(BuildContext context) async {
    await Share.share(RoomJoinLink.shareMessage(roomCode));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: EdgeInsets.all(compact ? 14 : 16),
      decoration: appInviteCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '邀请好友投票',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: colors.textPrimary),
          ),
          if (!compact) ...[
            const SizedBox(height: 6),
            Text(
              '把房间号或下方二维码发给好友，对方扫码即可入房：',
              style: TextStyle(fontSize: 12, color: colors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 4),
            Text(
              '① 扫码入房（推荐）\n'
              '② 首页 → 和朋友一起决定 → 加入房间\n'
              '③ 好友的房间列表（需先加好友）\n'
              '④ 创建后 30 分钟内有效，超时自动结束',
              style: TextStyle(fontSize: 12, color: colors.textSecondary, height: 1.5),
            ),
          ],
          if (_showQr) ...[
            const SizedBox(height: 14),
            Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.cardBorder),
                ),
                child: QrImageView(
                  data: RoomJoinLink.build(roomCode),
                  version: QrVersions.auto,
                  size: compact ? 132 : 160,
                  backgroundColor: colors.cardBackground,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: colors.textPrimary,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '扫码入房 · $roomCode',
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
            ),
          ] else if (compact) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => showRoomQrDialog(context, roomCode),
                icon: const Icon(Icons.qr_code_2_outlined),
                label: const Text('显示入房二维码'),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('房间号', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      roomCode,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                        color: colors.chipSelectedText,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _share(context),
                icon: const Icon(Icons.share_outlined, size: 18),
                label: const Text('分享'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () => _copy(context),
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

Future<void> showRoomQrDialog(BuildContext context, String roomCode) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('扫码入房'),
      content: SingleChildScrollView(
        child: RoomInviteCard(roomCode: roomCode, showQr: true),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('关闭')),
      ],
    ),
  );
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
          child: const Text('开始投票'),
        ),
      ],
    ),
  );
}
