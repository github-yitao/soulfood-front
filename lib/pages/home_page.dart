import 'package:flutter/material.dart';
import 'package:soulfood_front/routing/app_routes.dart';
import 'package:soulfood_front/widgets/feature_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DecideMeal',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                    color: Color(0xFF1E1F23),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '帮你更快决定吃什么 🙂',
                  style: TextStyle(
                    fontSize: 22,
                    color: Color(0xFF4D515A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Center(child: _AiChatEntryCard()),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: FeatureCard(
                    icon: Icons.groups_rounded,
                    iconColor: Color(0xFFFD7E7E),
                    title: '和朋友一起\n决定',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.friends),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: FeatureCard(
                    icon: Icons.soup_kitchen_rounded,
                    iconColor: Color(0xFF38BF7F),
                    title: '附近觅食\n(探店用呀)',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.nearby),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: FeatureCard(
                    icon: Icons.place_rounded,
                    iconColor: Color(0xFF8E7BFF),
                    title: '随机吃什么',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.nearby),
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

/// 首页主入口：圆盘视觉 + 底部明确 CTA，整体可点击进入 AI 对话
class _AiChatEntryCard extends StatefulWidget {
  const _AiChatEntryCard();

  @override
  State<_AiChatEntryCard> createState() => _AiChatEntryCardState();
}

class _AiChatEntryCardState extends State<_AiChatEntryCard> {
  bool _pressed = false;

  void _openAiChat() {
    Navigator.pushNamed(context, AppRoutes.aiChat);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '开始 AI 对话',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: _openAiChat,
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: const Duration(milliseconds: 120),
          child: Container(
            width: 300,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: _pressed ? 0.06 : 0.1),
                  blurRadius: _pressed ? 12 : 24,
                  offset: Offset(0, _pressed ? 4 : 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: Alignment(-0.2, -0.35),
                      radius: 1.05,
                      colors: [Color(0xFFFBF0A8), Color(0xFFF6CF57)],
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🍜', style: TextStyle(fontSize: 56)),
                      SizedBox(height: 8),
                      Text(
                        '帮我决定\n吃什么',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          height: 1.12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: Color(0xFF12151D),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E2430), Color(0xFF2D3748)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFD966), size: 18),
                      SizedBox(width: 8),
                      Text(
                        '开始 AI 对话',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white70, size: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '告诉我口味和心情，帮你推荐',
                  style: TextStyle(fontSize: 12, color: Color(0xFF8D919A)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
