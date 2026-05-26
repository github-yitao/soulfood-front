import 'package:flutter/material.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/core/theme/classic_brand_mark.dart';
import 'package:soulfood_front/core/theme/classic_brand_palette.dart';
import 'package:soulfood_front/core/theme/ghoul_eye_mark.dart';
import 'package:soulfood_front/core/theme/ghoul_theme_copy.dart';
import 'package:soulfood_front/routing/app_routes.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isGhoul = isGhoulTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('关于我们')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.bannerBackground, colors.cardBackground, colors.chipBackground],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.cardBorder),
            ),
            child: Column(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isGhoul
                          ? [colors.heroGradientStart, colors.heroGradientEnd]
                          : ClassicBrandPalette.heroGradient,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: isGhoul ? Border.all(color: colors.cardBorder) : null,
                  ),
                  child: Center(
                    child: isGhoul
                        ? const GhoulEyeMark(size: 44, glow: false)
                        : const ClassicBrandMark(size: 48, showPlate: false, glow: false),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('DecideMeal', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                  '让选择变得更简单。\n专注于「今天吃什么」的轻决策工具。',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.chipBorder),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: colors.chipText)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('用户协议'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.legalTerms),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('隐私政策'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.legalPrivacy),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.code_outlined),
                  title: const Text('开源许可'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showLicensePage(context: context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('我们在做什么', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    '通过偏好管理、历史记录、好友协作投票，帮助你快速完成吃饭决策。项目处于早期阶段，我们会持续迭代体验与稳定性。',
                    style: TextStyle(color: colors.textSecondary, height: 1.6),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'DecideMeal Team\nCopyright © 2026',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary, fontSize: 12, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
