import 'package:flutter/material.dart';
import 'package:soulfood_front/core/api/api_client.dart';
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
        MaterialPageRoute<void>(
          builder: (_) => RecipeResultPage(voteResult: result, roomCode: code),
        ),
      );
    } else {
      await Navigator.pushNamed(context, AppRoutes.vote, arguments: code);
    }
  }

  String get _actionLabel {
    switch (record.recordType) {
      case 'vote':
        return record.title.contains('结果') ? '查看投票结果' : '进入投票房间';
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
    return Scaffold(
      appBar: AppBar(title: const Text('记录详情')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Color(0x12000000), blurRadius: 12, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0E6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(record.typeIcon, color: const Color(0xFFFF8A43)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      record.typeLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6F7888),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  record.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(
                  record.detail,
                  style: const TextStyle(fontSize: 15, color: Color(0xFF6F7888), height: 1.5),
                ),
                const SizedBox(height: 12),
                Text(
                  record.dateText,
                  style: const TextStyle(fontSize: 13, color: Color(0xFFB3B8C2)),
                ),
                if (record.roomCode != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9FC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '关联房间号：${record.roomCode}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
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
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A43),
                minimumSize: const Size.fromHeight(48),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_actionLabel),
            ),
        ],
      ),
    );
  }
}
