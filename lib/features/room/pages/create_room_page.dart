import 'package:flutter/material.dart';
import 'package:soulfood_front/features/room/room_repository.dart';
import 'package:soulfood_front/features/room/widgets/room_invite_card.dart';
import 'package:soulfood_front/routing/app_routes.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final _topicCtrl = TextEditingController(text: '今晚吃什么？');
  final _repo = RoomRepository();
  int _maxPeople = 4;
  bool _loading = false;

  static const int _durationMin = 30;

  Future<void> _create() async {
    setState(() => _loading = true);
    try {
      final room = await _repo.createRoom(
        topic: _topicCtrl.text.trim(),
        maxPeople: _maxPeople,
        durationMin: _durationMin,
      );
      if (!mounted) return;
      await showRoomCreatedDialog(context, room.code);
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.vote,
        arguments: room.code,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('创建房间')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _topicCtrl,
            decoration: const InputDecoration(labelText: '本次主题', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          const Text('参与人数', style: TextStyle(fontWeight: FontWeight.w700)),
          Wrap(
            spacing: 8,
            children: [2, 4, 6, 8].map((n) {
              return ChoiceChip(
                label: Text('$n人'),
                selected: _maxPeople == n,
                onSelected: (_) => setState(() => _maxPeople = n),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFB8D4F0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.timer_outlined, color: Color(0xFF2B5EA8)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '投票限时 30 分钟，超时后系统自动统计票数并结束',
                    style: TextStyle(color: Color(0xFF2B5EA8), fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading ? null : _create,
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('创建并邀请好友'),
          ),
        ],
      ),
    );
  }
}
