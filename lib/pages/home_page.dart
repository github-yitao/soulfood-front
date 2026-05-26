import 'package:flutter/material.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/core/theme/app_theme_variant.dart';
import 'package:soulfood_front/core/theme/ghoul_eye_mark.dart';
import 'package:soulfood_front/routing/app_routes.dart';
import 'package:soulfood_front/widgets/feature_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isGhoul = AppServices.I.appearance.variant == AppThemeVariant.ghoul;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
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
                        isGhoul ? '在喰与之间，选出今晚的归宿' : '帮你更快决定吃什么 🙂',
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
                Material(
                  color: colors.cardBackground,
                  shape: CircleBorder(
                    side: BorderSide(color: colors.cardBorder),
                  ),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(Icons.settings_outlined, size: 20, color: colors.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(flex: 2),
            const Center(child: _HomeHero()),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FeatureCard(
                    icon: Icons.groups_rounded,
                    iconColor: isGhoul ? const Color(0xFFFF3B30) : const Color(0xFFFF6268),
                    title: '和朋友一起\n决定',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.friends),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FeatureCard(
                    icon: Icons.touch_app_rounded,
                    iconColor: isGhoul ? const Color(0xFFC0C0C0) : const Color(0xFF3ABC77),
                    title: '附近觅食\n(探店用呀)',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.nearby),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FeatureCard(
                    icon: Icons.location_on_rounded,
                    iconColor: isGhoul ? const Color(0xFF757575) : const Color(0xFF8D6DF2),
                    title: '随机吃什么',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.randomEat),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FeatureCard(
                    icon: Icons.auto_awesome_rounded,
                    iconColor: isGhoul ? const Color(0xFFFF3B30) : const Color(0xFF2B5EA8),
                    title: 'AI 推荐\n菜谱',
                    backgroundColor: isGhoul ? const Color(0xFF1C1C1E) : const Color(0xFFEEF4FF),
                    borderColor: isGhoul ? const Color(0xFF4A4A48) : const Color(0xFFB8D4F8),
                    textColor: isGhoul ? const Color(0xFFE6E6E6) : const Color(0xFF2B5EA8),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.aiQuick),
                  ),
                ),
              ],
            ),
            const Spacer(flex: 3),
            Center(
              child: TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.recipeLibrary),
                icon: const Icon(Icons.menu_book_outlined, size: 16),
                label: const Text('浏览菜品库', style: TextStyle(fontSize: 13)),
                style: TextButton.styleFrom(foregroundColor: colors.textSecondary),
              ),
            ),
          ],
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
    final isGhoul = AppServices.I.appearance.variant == AppThemeVariant.ghoul;

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
            width: 236,
            height: 236,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isGhoul
                  ? RadialGradient(
                      center: const Alignment(0.2, -0.1),
                      radius: 0.95,
                      colors: [colors.heroGradientStart, colors.heroGradientEnd],
                    )
                  : const RadialGradient(
                      center: Alignment(0.36, 0.24),
                      radius: 0.78,
                      colors: [Color(0xFFFBF0A8), Color(0xFFF6CF57)],
                    ),
              border: isGhoul ? Border.all(color: const Color(0xFF4A4A48), width: 1.5) : null,
              boxShadow: [
                BoxShadow(
                  color: isGhoul
                      ? colors.accent.withValues(alpha: _pressed ? 0.15 : 0.28)
                      : Colors.black.withValues(alpha: _pressed ? 0.03 : 0.04),
                  blurRadius: isGhoul ? 28 : 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isGhoul)
                  const GhoulEyeMark(size: 88, glow: true)
                else
                  const Text('🍜', style: TextStyle(fontSize: 48)),
                SizedBox(height: isGhoul ? 10 : 12),
                Text(
                  isGhoul ? '帮我决定\n吃什么' : '帮我决定\n吃什么',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isGhoul ? 26 : 30,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                    letterSpacing: isGhoul ? 0.2 : -0.6,
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
