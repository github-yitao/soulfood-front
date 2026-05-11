import 'package:flutter/material.dart';
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
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.settings, color: Color(0xFF363940)),
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD966),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x26000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🍜', style: TextStyle(fontSize: 68)),
                      SizedBox(height: 12),
                      Text(
                        '帮我决定\n吃什么',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 48,
                          height: 1.16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF18191D),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 34),
            const Row(
              children: [
                Expanded(
                  child: FeatureCard(
                    icon: Icons.groups_rounded,
                    iconColor: Color(0xFFFD7E7E),
                    title: '和朋友一起\n决定',
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: FeatureCard(
                    icon: Icons.soup_kitchen_rounded,
                    iconColor: Color(0xFF38BF7F),
                    title: '做饭模式\n(有啥做啥)',
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: FeatureCard(
                    icon: Icons.place_rounded,
                    iconColor: Color(0xFF8E7BFF),
                    title: '附近吃什么',
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