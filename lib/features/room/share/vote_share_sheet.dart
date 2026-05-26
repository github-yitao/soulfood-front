import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/features/room/share/vote_share_card_widget.dart';
import 'package:soulfood_front/features/room/share/vote_share_data.dart';

/// 投票结果分享：预览卡片、导出图片、复制文案。
class VoteShareSheet {
  VoteShareSheet._();

  static Future<void> show(BuildContext context, VoteShareData data) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _VoteShareSheetBody(data: data),
    );
  }

  static Future<Uint8List?> capturePng(BuildContext context, VoteShareData data) async {
    final key = GlobalKey();
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (overlayContext) => Positioned(
        left: -VoteShareCardWidget.cardWidth * 2,
        top: 0,
        child: Material(
          color: Colors.transparent,
          child: RepaintBoundary(
            key: key,
            child: VoteShareCardWidget(data: data),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await WidgetsBinding.instance.endOfFrame;

    Uint8List? bytes;
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 3);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          bytes = byteData.buffer.asUint8List();
        }
      }
    } finally {
      entry.remove();
    }
    return bytes;
  }
}

class _VoteShareSheetBody extends StatefulWidget {
  const _VoteShareSheetBody({required this.data});

  final VoteShareData data;

  @override
  State<_VoteShareSheetBody> createState() => _VoteShareSheetBodyState();
}

class _VoteShareSheetBodyState extends State<_VoteShareSheetBody> {
  bool _sharingImage = false;

  Future<void> _copyText() async {
    await Clipboard.setData(ClipboardData(text: widget.data.buildShareText()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('分享文案已复制')),
    );
  }

  Future<void> _shareImage() async {
    setState(() => _sharingImage = true);
    try {
      final bytes = await VoteShareSheet.capturePng(context, widget.data);
      if (!mounted) return;
      if (bytes == null || bytes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('生成分享图失败，请重试')),
        );
        return;
      }
      await Share.shareXFiles(
        [
          XFile.fromData(
            bytes,
            mimeType: 'image/png',
            name: 'decidemeal_vote_result.png',
          ),
        ],
        text: widget.data.buildShareText(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _sharingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final previewScale = (MediaQuery.sizeOf(context).width - 48) / VoteShareCardWidget.cardWidth;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                widget.data.ghoul ? '生成喰迹分享卡' : '生成分享卡',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                '预览后分享图片或复制文案给好友',
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
              ),
              const SizedBox(height: 16),
              Center(
                child: Transform.scale(
                  scale: previewScale.clamp(0.72, 1.0),
                  child: VoteShareCardWidget(data: widget.data),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _copyText,
                      icon: const Icon(Icons.content_copy_rounded, size: 18),
                      label: const Text('复制文案'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _sharingImage ? null : _shareImage,
                      icon: _sharingImage
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: colors.onAccent),
                            )
                          : const Icon(Icons.ios_share_rounded, size: 18),
                      label: Text(widget.data.ghoul ? '分享喰迹' : '分享图片'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('关闭'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
