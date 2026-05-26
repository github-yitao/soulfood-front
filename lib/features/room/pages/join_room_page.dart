import 'package:flutter/material.dart';
import 'package:soulfood_front/core/storage/recent_rooms_store.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/core/theme/theme_widgets.dart';
import 'package:soulfood_front/features/room/room_join_flow.dart';
import 'package:soulfood_front/routing/app_routes.dart';

class JoinRoomPage extends StatefulWidget {
  const JoinRoomPage({super.key});

  @override
  State<JoinRoomPage> createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  final _codeCtrl = TextEditingController();
  final _recentStore = RecentRoomsStore();
  bool _loading = false;
  List<String> _recentCodes = const [];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRecent() async {
    final codes = await _recentStore.load();
    if (mounted) setState(() => _recentCodes = codes);
  }

  Future<void> _join(String code) async {
    setState(() => _loading = true);
    try {
      await joinRoomAndNavigate(context, code);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _joinFromInput() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入 6 位房间号')));
      return;
    }
    await _join(code);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      appBar: AppBar(title: const Text('加入房间')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_recentCodes.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: appInviteCardDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('最近房间', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _recentCodes.map((code) {
                      return ActionChip(
                        label: Text(code, style: const TextStyle(letterSpacing: 2, fontWeight: FontWeight.w700)),
                        onPressed: _loading ? null : () => _join(code),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: appCardDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '扫码入房',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  '让好友展示投票页上的二维码，扫码即可加入',
                  style: TextStyle(fontSize: 13, color: colors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: _loading
                      ? null
                      : () => Navigator.pushNamed(context, AppRoutes.scanJoinRoom),
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
                  style: TextStyle(color: colors.textSecondary, fontSize: 13),
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
            onPressed: _loading ? null : _joinFromInput,
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('进入投票'),
          ),
        ],
      ),
    );
  }
}
