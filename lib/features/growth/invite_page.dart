import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/core/theme/theme_widgets.dart';
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _inviteMessage(String code) => '快来 DecideMeal 一起吃饭投票选店！我的邀请码：$code';

  Future<void> _copyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('邀请码已复制')));
    }
  }

  Future<void> _copyAndHint(String channel, String code) async {
    await Clipboard.setData(ClipboardData(text: _inviteMessage(code)));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('邀请文案已复制，请粘贴到$channel')));
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
          '每成功邀请 1 位好友，进度 +1；累计邀请 5 位可解锁「组局达人」徽章。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final overview = _overview;
    final colors = context.appColors;
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
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: colors.chipSelectedBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.chipSelectedBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.campaign_outlined,
                        color: colors.accent,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '邀请页已升级：可复制邀请码、分享给好友、查看邀请进度',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colors.heroGradientStart,
                                colors.heroGradientEnd,
                                colors.accent,
                              ],
                              stops: const [0.0, 0.55, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: colors.accent.withValues(alpha: 0.28),
                                blurRadius: 24,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '邀请 1 位好友，\n一起加入吃饭小队',
                                style: TextStyle(
                                  color: colors.heroText,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  height: 1.24,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '好友注册后即可一起投票选店，解锁「组局达人」徽章',
                                style: TextStyle(
                                  color: colors.heroText.withValues(alpha: 0.9),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (overview != null) ...[
                          if (overview.badgeUnlocked)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: appStatusDecoration(
                                colors,
                                AppStatusKind.warning,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.military_tech,
                                    color: appStatusTextColor(
                                      colors,
                                      AppStatusKind.warning,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '已解锁「组局达人」徽章',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: appStatusTextColor(
                                          colors,
                                          AppStatusKind.warning,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: appCardDecoration(context, radius: 18),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '我的邀请码',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        overview.inviteCode,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1,
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      _copyCode(overview.inviteCode),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    '复制',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
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
                                onTap: () =>
                                    _copyAndHint('微信', overview.inviteCode),
                              ),
                              const SizedBox(width: 10),
                              _ShareTile(
                                icon: Icons.forum_outlined,
                                label: '朋友圈',
                                onTap: () =>
                                    _copyAndHint('朋友圈', overview.inviteCode),
                              ),
                              const SizedBox(width: 10),
                              _ShareTile(
                                icon: Icons.mail_outline,
                                label: 'QQ',
                                onTap: () =>
                                    _copyAndHint('QQ', overview.inviteCode),
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
                            decoration: appMutedSurfaceDecoration(context),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '本月邀请进度',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${overview.completedCount} / ${overview.targetCount} 人',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: overview.targetCount == 0
                                        ? 0
                                        : overview.completedCount /
                                              overview.targetCount,
                                    backgroundColor: colors.progressTrack,
                                    color: colors.accent,
                                    minHeight: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: appCardDecoration(context, radius: 18),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    14,
                                    12,
                                    14,
                                    12,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '邀请记录',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        '最近 30 天',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(height: 1, color: colors.cardBorder),
                                if (overview.records.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 24,
                                    ),
                                    child: Text(
                                      '暂无邀请记录',
                                      style: TextStyle(
                                        color: colors.textSecondary,
                                      ),
                                    ),
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
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: appCardDecoration(context, radius: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '邀请信息暂未加载成功',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '请检查网络后重试。加载成功后可查看邀请码、邀请进度和邀请记录。',
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.45,
                                    color: colors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: _load,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('重新加载邀请信息'),
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
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: FilledButton(
                        onPressed: overview == null
                            ? null
                            : () => _shareInvite(overview.inviteCode),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          overview == null ? '加载邀请码中…' : '立即邀请好友',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
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
    final colors = context.appColors;
    return Expanded(
      child: Material(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: appCardDecoration(context, radius: 16),
            child: Column(
              children: [
                Icon(icon, size: 20, color: colors.accent),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.chipText,
                  ),
                ),
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
    final avatarColors = _avatarGradients[index % _avatarGradients.length];
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.cardBorder)),
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
                    gradient: LinearGradient(colors: avatarColors),
                  ),
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: colors.onAccent,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.nickname,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: colors.textPrimary,
                        ),
                      ),
                      if (record.registeredAt.isNotEmpty)
                        Text(
                          '${record.registeredAt} 注册',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: appStatusDecoration(
              colors,
              done ? AppStatusKind.success : AppStatusKind.warning,
            ),
            child: Text(
              record.statusLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: appStatusTextColor(
                  colors,
                  done ? AppStatusKind.success : AppStatusKind.warning,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
