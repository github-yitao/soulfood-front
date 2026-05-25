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
            const Center(child: _AiChatHeroButton()),
            const SizedBox(height: 34),
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

/// 首页主入口：进入 AI 对话（明确可点击）
class _AiChatHeroButton extends StatefulWidget {
  const _AiChatHeroButton();

  @override
  State<_AiChatHeroButton> createState() => _AiChatHeroButtonState();
}

class _AiChatHeroButtonState extends State<_AiChatHeroButton> {
  bool _pressed = false;

  void _openAiChat() {
    Navigator.pushNamed(context, AppRoutes.aiChat);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '开始 AI 对话，帮我决定吃什么',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: _openAiChat,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1,
          duration: const Duration(milliseconds: 120),
          child: Container(
            width: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD966).withValues(alpha: 0.55),
                  blurRadius: _pressed ? 8 : 22,
                  offset: Offset(0, _pressed ? 4 : 10),
                ),
                const BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD966),
                border: Border.all(color: const Color(0xFFFFB800), width: 3),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Positioned(
                    top: 28,
                    child: _AiBadge(),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat_bubble_rounded,
                          size: 40,
                          color: Color(0xFF18191D),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('🍜', style: TextStyle(fontSize: 36)),
                      const SizedBox(height: 6),
                      const Text(
                        'AI 帮我决定',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 34,
                          height: 1.15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF18191D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '吃什么',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 34,
                          height: 1.15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF18191D).withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                  const Positioned(
                    bottom: 26,
                    child: _StartChatChip(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AiBadge extends StatelessWidget {
  const _AiBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1F23),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 14, color: Color(0xFFFFD966)),
          SizedBox(width: 4),
          Text(
            'AI 对话',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StartChatChip extends StatelessWidget {
  const _StartChatChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(color: Color(0x18000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '点击开始聊天',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF18191D),
            ),
          ),
          SizedBox(width: 4),
          Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF18191D)),
        ],
      ),
    );
  }
}
