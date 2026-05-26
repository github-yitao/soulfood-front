import 'package:flutter/material.dart';
import 'package:soulfood_front/core/storage/recent_rooms_store.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/core/theme/theme_widgets.dart';
import 'package:soulfood_front/features/room/room_join_flow.dart';

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

  List<String> get _recentPreview => _recentCodes.take(3).toList();

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

  Future<void> _openRecentHistory() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => _RecentRoomsPage(codes: _recentCodes, onSelect: _join),
      ),
    );
  }

  Future<void> _joinFromInput() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入 6 位房间号')));
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
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          '最近房间',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (_recentCodes.length > 3)
                        TextButton(
                          onPressed: _loading ? null : _openRecentHistory,
                          child: const Text('更多'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _recentPreview.map((code) {
                      return ActionChip(
                        label: Text(
                          code,
                          style: const TextStyle(
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: _loading ? null : () => _join(code),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            '输入 6 位房间号加入',
            style: TextStyle(fontSize: 14, color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _codeCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 6,
            ),
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
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('进入投票'),
          ),
        ],
      ),
    );
  }
}

class _RecentRoomsPage extends StatelessWidget {
  const _RecentRoomsPage({required this.codes, required this.onSelect});

  final List<String> codes;
  final Future<void> Function(String code) onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      appBar: AppBar(title: const Text('最近记录')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: codes.length,
        separatorBuilder: (_, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final code = codes[index];
          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: colors.cardBorder),
            ),
            tileColor: colors.cardBackground,
            title: Text(
              code,
              style: TextStyle(
                letterSpacing: 2,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              Navigator.pop(context);
              await onSelect(code);
            },
          );
        },
      ),
    );
  }
}
