import 'package:flutter/material.dart';
import 'package:soulfood_front/features/room/room_join_flow.dart';
import 'package:soulfood_front/routing/app_routes.dart';

class JoinRoomPage extends StatefulWidget {
  const JoinRoomPage({super.key});

  @override
  State<JoinRoomPage> createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入 6 位房间号')));
      return;
    }
    setState(() => _loading = true);
    try {
      await joinRoomAndNavigate(context, code);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('加入房间')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEDF1F6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '扫码入房',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                const Text(
                  '让好友展示投票页上的二维码，扫码即可加入',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6F7888), height: 1.4),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: _loading
                      ? null
                      : () => Navigator.pushNamed(context, AppRoutes.scanJoinRoom),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8A43),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('打开扫码'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '或输入房间号',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _codeCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 6),
            decoration: const InputDecoration(
              labelText: '6 位房间号',
              hintText: '123456',
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _loading ? null : _join,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: const Color(0xFF1B2538),
            ),
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('进入投票'),
          ),
        ],
      ),
    );
  }
}
