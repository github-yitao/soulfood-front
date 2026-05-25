import 'package:flutter/material.dart';
import 'package:soulfood_front/features/room/room_models.dart';

/// 投票结果页（仅展示 API 结果，AI 菜谱推荐下一阶段再做）
class VoteResultPage extends StatelessWidget {
  const VoteResultPage({super.key, required this.result, this.roomCode});

  final RoomResult result;
  final String? roomCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('投票结果')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFD79F)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '今天就吃',
                    style: TextStyle(fontSize: 16, color: Color(0xFF6F7888)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E1F23),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${result.voteCount} 票 · ${result.percent}%',
                    style: const TextStyle(fontSize: 15, color: Color(0xFFD86A00)),
                  ),
                ],
              ),
            ),
            if (roomCode != null) ...[
              const SizedBox(height: 12),
              Text('房间号 $roomCode', style: const TextStyle(color: Color(0xFF8D919A))),
            ],
            const SizedBox(height: 24),
            const Text(
              'AI 菜谱推荐将在下一阶段接入。',
              style: TextStyle(color: Color(0xFF8D919A), fontSize: 14),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: const Color(0xFFFF8A43),
              ),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    );
  }
}
