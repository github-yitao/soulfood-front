import 'package:flutter/material.dart';
import 'package:soulfood_front/routing/app_routes.dart';
import 'package:soulfood_front/widgets/feature_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DecideMeal',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          letterSpacing: -0.2,
                          color: Color(0xFF1E1F23),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '帮你更快决定吃什么 🙂',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF747B87),
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.white,
                  shape: CircleBorder(
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.settings_outlined, size: 20, color: Color(0xFF4D515A)),
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
                    iconColor: Color(0xFFFF6268),
                    title: '和朋友一起\n决定',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.friends),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FeatureCard(
                    icon: Icons.touch_app_rounded,
                    iconColor: Color(0xFF3ABC77),
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
                    iconColor: Color(0xFF8D6DF2),
                    title: '随机吃什么',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.randomEat),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FeatureCard(
                    icon: Icons.auto_awesome_rounded,
                    iconColor: Color(0xFF2B5EA8),
                    title: 'AI 推荐\n菜谱',
                    backgroundColor: Color(0xFFEEF4FF),
                    borderColor: Color(0xFFB8D4F8),
                    textColor: Color(0xFF2B5EA8),
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
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF8D919A)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 原型 home-hero：黄圆 + 插画 + 文案，点击进入 AI 对话
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
              gradient: const RadialGradient(
                center: Alignment(0.36, 0.24),
                radius: 0.78,
                colors: [Color(0xFFFBF0A8), Color(0xFFF6CF57)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: _pressed ? 0.03 : 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🍜', style: TextStyle(fontSize: 48)),
                SizedBox(height: 12),
                Text(
                  '帮我决定\n吃什么',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                    color: Color(0xFF12151D),
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
