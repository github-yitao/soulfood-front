import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soulfood_front/features/growth/invite_repository.dart';

class InvitePage extends StatefulWidget {
  const InvitePage({super.key});

  @override
  State<InvitePage> createState() => _InvitePageState();
}

class _InvitePageState extends State<InvitePage> {
  final _repo = InviteRepository();
  InviteOverview? _overview;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _repo.loadOverview();
      if (mounted) setState(() => _overview = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _copyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('邀请码已复制')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final overview = _overview;
    return Scaffold(
      appBar: AppBar(title: const Text('邀请好友')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9F52), Color(0xFFFF6F61), Color(0xFF7F5CFF)],
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '邀请 1 位好友，\n一起加入吃饭小队',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '好友注册时填写你的邀请码即可加入',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (overview != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFEDF1F6)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('我的邀请码', style: TextStyle(fontSize: 12, color: Color(0xFF778197))),
                                const SizedBox(height: 4),
                                Text(
                                  overview.inviteCode,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 1),
                                ),
                              ],
                            ),
                          ),
                          FilledButton(
                            onPressed: () => _copyCode(overview.inviteCode),
                            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1B2538)),
                            child: const Text('复制'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '本月邀请进度 ${overview.completedCount} / ${overview.targetCount} 人',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: overview.targetCount == 0
                          ? 0
                          : overview.completedCount / overview.targetCount,
                      backgroundColor: const Color(0xFFE8EDF4),
                      color: const Color(0xFFFF7A43),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    const SizedBox(height: 16),
                    const Text('邀请记录', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 8),
                    if (overview.records.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text('暂无邀请记录', style: TextStyle(color: Color(0xFF8D919A)))),
                      )
                    else
                      ...overview.records.map(
                        (r) => Card(
                          child: ListTile(
                            title: Text(r.nickname, style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text(r.registeredAt),
                            trailing: Text(r.statusLabel, style: const TextStyle(color: Color(0xFF0F9F55), fontSize: 12)),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
    );
  }
}
