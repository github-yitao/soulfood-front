import 'package:flutter/material.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/core/theme/classic_theme_copy.dart';
import 'package:soulfood_front/core/theme/ghoul_theme_copy.dart';
import 'package:soulfood_front/core/theme/ghoul_eye_mark.dart';
import 'package:soulfood_front/features/notification/notification_repository.dart';
import 'package:soulfood_front/routing/app_routes.dart';
import 'package:soulfood_front/widgets/feature_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _notificationRepo = NotificationRepository(AppServices.I.api);
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final overview = await _notificationRepo.load();
      if (mounted) setState(() => _unreadNotifications = overview.unreadCount);
    } catch (_) {}
  }

  Future<void> _openNotifications() async {
    await Navigator.pushNamed(context, AppRoutes.notifications);
    _loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isGhoul = isGhoulTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DecideMeal',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          letterSpacing: isGhoul ? 0.6 : -0.2,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isGhoul ? '在饥饿与纠结之间，选出今晚的归宿' : '帮你更快决定吃什么 🙂',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                _HeaderIconButton(
                  icon: Icons.notifications_outlined,
                  badge: _unreadNotifications > 0 ? _unreadNotifications : null,
                  onTap: _openNotifications,
                ),
                const SizedBox(width: 6),
                _HeaderIconButton(
                  icon: Icons.settings_outlined,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Center(child: _HomeHero()),
            const SizedBox(height: 20),
            Text(
              ghoulThemedText('一起决定', ghoul: '暗夜组局'),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: colors.textPrimary),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FeatureCard(
                    icon: Icons.groups_rounded,
                    iconColor: colors.accent,
                    title: '和朋友一起\n决定',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.friends),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FeatureCard(
                    icon: Icons.group_add_outlined,
                    iconColor: colors.warningText,
                    title: '邀请好友\n一起组局',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.invite),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              ghoulThemedText('AI 助手', ghoul: '喰种智囊'),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: colors.textPrimary),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FeatureCard(
                    icon: Icons.auto_awesome_rounded,
                    iconColor: isGhoul ? colors.accent : colors.infoText,
                    title: 'AI 推荐\n菜谱',
                    backgroundColor: isGhoul ? colors.cardBackground : colors.infoBackground,
                    borderColor: isGhoul ? colors.cardBorder : colors.infoBorder,
                    textColor: isGhoul ? colors.featureDefaultText : colors.infoText,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.aiQuick),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FeatureCard(
                    icon: Icons.forum_outlined,
                    iconColor: colors.textSecondary,
                    title: 'AI 对话\n记录',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.aiConversations),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.cardBackground,
      shape: CircleBorder(side: BorderSide(color: colors.cardBorder)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Badge(
            isLabelVisible: badge != null && badge! > 0,
            label: Text('${badge ?? 0}'),
            child: Icon(icon, size: 20, color: colors.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _HomeHero extends StatefulWidget {
  const _HomeHero();

  @override
  State<_HomeHero> createState() => _HomeHeroState();
}

class _HomeHeroState extends State<_HomeHero> {
  bool _pressed = false;

  void _openAiChat() {
    Navigator.pushNamed(context, AppRoutes.aiChat, arguments: 'new');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isGhoul = isGhoulTheme;

    return Semantics(
      button: true,
      label: '帮我决定吃什么',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: _openAiChat,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          child: Container(
            width: isGhoul ? 220 : 200,
            height: isGhoul ? 220 : 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isGhoul ? null : colors.heroGradientStart,
              gradient: isGhoul
                  ? RadialGradient(
                      center: const Alignment(0.2, -0.1),
                      radius: 0.95,
                      colors: [colors.heroGradientStart, colors.heroGradientEnd],
                    )
                  : null,
              border: Border.all(
                color: isGhoul ? colors.cardBorder : colors.cardBorder,
                width: isGhoul ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isGhoul
                      ? colors.accent.withValues(alpha: _pressed ? 0.15 : 0.28)
                      : Colors.black.withValues(alpha: _pressed ? 0.04 : 0.06),
                  blurRadius: isGhoul ? 28 : 24,
                  offset: Offset(0, isGhoul ? 12 : 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isGhoul) ...[
                  const GhoulEyeMark(size: 80, glow: true),
                  const SizedBox(height: 8),
                ] else ...[
                  Icon(Icons.restaurant_menu_rounded, size: 32, color: colors.accent),
                  const SizedBox(height: 14),
                ],
                Text(
                  isGhoul
                      ? '今夜喰\n什么'
                      : classicThemedText('帮我决定\n吃什么', warm: '今晚吃\n什么'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isGhoul ? 24 : 20,
                    height: 1.25,
                    fontWeight: isGhoul ? FontWeight.w900 : FontWeight.w600,
                    letterSpacing: isGhoul ? 0.2 : -0.2,
                    color: colors.heroText,
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
