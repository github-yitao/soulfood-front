import 'package:flutter/material.dart';
import 'package:soulfood_front/features/room/room_repository.dart';
import 'package:soulfood_front/routing/app_routes.dart';

class JoinRoomPage extends StatefulWidget {
  const JoinRoomPage({super.key});

  @override
  State<JoinRoomPage> createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  final _codeCtrl = TextEditingController();
  final _repo = RoomRepository();
  bool _loading = false;

  Future<void> _join() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入 6 位房间号')));
      return;
    }
    setState(() => _loading = true);
    try {
      await _repo.joinRoom(code);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.vote, arguments: code);
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
      appBar: AppBar(title: const Text('加入房间')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _codeCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: '房间号',
                hintText: '123456',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _loading ? null : _join,
              child: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('进入投票'),
            ),
          ],
        ),
      ),
    );
  }
}
