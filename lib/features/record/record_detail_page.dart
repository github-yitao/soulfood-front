import 'package:flutter/material.dart';
import 'package:soulfood_front/core/api/api_client.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/core/theme/theme_widgets.dart';
import 'package:soulfood_front/features/favorite/favorites_page.dart';
import 'package:soulfood_front/features/record/record_models.dart';
import 'package:soulfood_front/features/room/pages/recipe_result_page.dart';
import 'package:soulfood_front/features/room/room_repository.dart';
import 'package:soulfood_front/routing/app_routes.dart';

class RecordDetailPage extends StatefulWidget {
  const RecordDetailPage({super.key, required this.record});

  final RecordItem record;

  @override
  State<RecordDetailPage> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  final _roomRepo = RoomRepository();
  bool _loading = false;

  RecordItem get record => widget.record;

  Future<void> _openRelated() async {
    setState(() => _loading = true);
    try {
      switch (record.recordType) {
        case 'vote':
          await _openVoteRecord();
        case 'favorite':
          if (!mounted) return;
          await Navigator.push<void>(
            context,
            MaterialPageRoute<void>(builder: (_) => const FavoritesPage()),
          );
        case 'eat':
          if (!mounted) return;
          await Navigator.pushNamed(context, AppRoutes.nearby);
        case 'ai_recommend':
          if (!mounted) return;
          await Navigator.pushNamed(context, AppRoutes.aiQuick);
        default:
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('暂无关联页面')),
            );
          }
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openVoteRecord() async {
    final code = record.roomCode;
    if (code == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('未找到房间号，无法打开投票')),
        );
      }
      return;
    }

    final room = await _roomRepo.getRoom(code);
    if (!mounted) return;

    if (room.status == 'closed') {
      final result = _roomRepo.resultFromDetail(room);
      if (!mounted) return;
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(builder: (_) => RecipeResultPage(voteResult: result)),
      );
    } else {
      await Navigator.pushNamed(context, AppRoutes.vote, arguments: code);
    }
  }

  String get _actionLabel {
    switch (record.recordType) {
      case 'vote':
        return '查看投票结果';
      case 'favorite':
        return '查看我的收藏';
      case 'eat':
        return '查看附近餐厅';
      case 'ai_recommend':
        return '打开 AI 推荐';
      default:
        return '查看详情';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(title: const Text('记录详情')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: appCardDecoration(context, radius: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colors.chipSelectedBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.chipSelectedBorder),
                      ),
                      child: Icon(record.typeIcon, color: colors.accent),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      record.typeLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  record.title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: colors.textPrimary),
                ),
                const SizedBox(height: 10),
                Text(
                  record.detail,
                  style: TextStyle(fontSize: 15, color: colors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 12),
                Text(
                  record.dateText,
                  style: TextStyle(fontSize: 13, color: colors.offline),
                ),
                if (record.roomCode != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: appMutedSurfaceDecoration(context),
                    child: Text(
                      '关联房间号：${record.roomCode}',
                      style: TextStyle(fontWeight: FontWeight.w700, color: colors.textPrimary),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (record.recordType.isNotEmpty)
            FilledButton(
              onPressed: _loading ? null : _openRelated,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: _loading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: colors.onAccent),
                    )
                  : Text(_actionLabel),
            ),
        ],
      ),
    );
  }
}
