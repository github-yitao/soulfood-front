import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
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

  String _inviteMessage(String code) =>
      '快来 DecideMeal 一起吃饭投票选店！我的邀请码：$code';

  Future<void> _copyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('邀请码已复制')));
    }
  }

  Future<void> _copyAndHint(String channel, String code) async {
    await Clipboard.setData(ClipboardData(text: _inviteMessage(code)));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('邀请文案已复制，请粘贴到$channel')),
      );
    }
  }

  Future<void> _shareInvite(String code) async {
    await Share.share(_inviteMessage(code));
  }

  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('邀请规则'),
        content: const Text(
          '好友注册时填写你的邀请码即可加入吃饭小队。\n\n'
          '每成功邀请 1 位好友，进度 +1；累计邀请 5 位可解锁「组局达人」徽章（即将上线）。',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('知道了')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final overview = _overview;
    return Scaffold(
      appBar: AppBar(
        title: const Text('邀请好友'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: '邀请规则',
            onPressed: _showHelp,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFFF9F52), Color(0xFFFF6F61), Color(0xFF7F5CFF)],
                              stops: [0.0, 0.55, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF7854).withValues(alpha: 0.28),
                                blurRadius: 24,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '邀请 1 位好友，\n一起加入吃饭小队',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  height: 1.24,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                '好友注册后即可一起投票选店，解锁「组局达人」徽章',
                                style: TextStyle(color: Color(0xF0FFFFFF), fontSize: 14, height: 1.5),
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
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x141E2941),
                                  blurRadius: 22,
                                  offset: Offset(0, 10),
                                ),
                              ],
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
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                FilledButton(
                                  onPressed: () => _copyCode(overview.inviteCode),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF1B2538),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('复制', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _ShareTile(
                                icon: Icons.chat_bubble_outline,
                                label: '微信',
                                onTap: () => _copyAndHint('微信', overview.inviteCode),
                              ),
                              const SizedBox(width: 10),
                              _ShareTile(
                                icon: Icons.forum_outlined,
                                label: '朋友圈',
                                onTap: () => _copyAndHint('朋友圈', overview.inviteCode),
                              ),
                              const SizedBox(width: 10),
                              _ShareTile(
                                icon: Icons.mail_outline,
                                label: 'QQ',
                                onTap: () => _copyAndHint('QQ', overview.inviteCode),
                              ),
                              const SizedBox(width: 10),
                              _ShareTile(
                                icon: Icons.share_outlined,
                                label: '更多',
                                onTap: () => _shareInvite(overview.inviteCode),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBFCFF),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFEDF1F6)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      '本月邀请进度',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2B3342)),
                                    ),
                                    Text(
                                      '${overview.completedCount} / ${overview.targetCount} 人',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2B3342)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: overview.targetCount == 0
                                        ? 0
                                        : overview.completedCount / overview.targetCount,
                                    backgroundColor: const Color(0xFFE8EDF4),
                                    color: const Color(0xFFFF7A43),
                                    minHeight: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFEDF1F6)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x141E2941),
                                  blurRadius: 22,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(14, 12, 14, 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('邀请记录', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF202838))),
                                      Text('最近 30 天', style: TextStyle(fontSize: 12, color: Color(0xFF758095))),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1, color: Color(0xFFF2F4F8)),
                                if (overview.records.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Text('暂无邀请记录', style: TextStyle(color: Color(0xFF8D919A))),
                                  )
                                else
                                  ...overview.records.asMap().entries.map(
                                        (entry) => _InviteRecordRow(
                                          record: entry.value,
                                          index: entry.key,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (overview != null)
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFB35C), Color(0xFFFF7F43)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF783A).withValues(alpha: 0.28),
                                blurRadius: 18,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => _shareInvite(overview.inviteCode),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('立即邀请好友', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _ShareTile extends StatelessWidget {
  const _ShareTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEDF1F6)),
              boxShadow: const [
                BoxShadow(color: Color(0x0F20293D), blurRadius: 14, offset: Offset(0, 6)),
              ],
            ),
            child: Column(
              children: [
                Icon(icon, size: 20, color: const Color(0xFFFF7A22)),
                const SizedBox(height: 6),
                Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF5F697A))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InviteRecordRow extends StatelessWidget {
  const _InviteRecordRow({required this.record, required this.index});

  final InviteRecord record;
  final int index;

  static const _avatarGradients = [
    [Color(0xFF8CC8FF), Color(0xFF4D8DFF)],
    [Color(0xFF9DE2CA), Color(0xFF31B18F)],
    [Color(0xFFFFC7B0), Color(0xFFFF8C67)],
  ];

  @override
  Widget build(BuildContext context) {
    final done = record.statusLabel.contains('已加入');
    final initial = record.nickname.isNotEmpty ? record.nickname[0] : '友';
    final colors = _avatarGradients[index % _avatarGradients.length];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF4F6FA))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: colors),
                  ),
                  child: Text(
                    initial,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.nickname, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1F2633))),
                      if (record.registeredAt.isNotEmpty)
                        Text(
                          '${record.registeredAt} 注册',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF778195)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: done ? const Color(0xFFECFDF3) : const Color(0xFFFFF4E7),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: done ? const Color(0xFFBDECCF) : const Color(0xFFFFD8B1)),
            ),
            child: Text(
              record.statusLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: done ? const Color(0xFF0F9F55) : const Color(0xFFCF6C16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
