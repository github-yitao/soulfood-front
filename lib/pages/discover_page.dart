import 'package:flutter/material.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/core/theme/app_theme_variant.dart';
import 'package:soulfood_front/routing/app_routes.dart';
import 'package:soulfood_front/widgets/feature_card.dart';

/// 底部 Tab：探店、地图、随机吃、居家做饭等「去哪吃 / 怎么做」。
class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isGhoul = AppServices.I.appearance.variant == AppThemeVariant.ghoul;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '觅食',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isGhoul ? '出门探店，或在家动手做' : '看看附近有什么好吃的，或在家开伙',
              style: TextStyle(fontSize: 13, color: colors.textSecondary, height: 1.35),
            ),
            const SizedBox(height: 24),
            Text(
              '出门探店',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: colors.textPrimary),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FeatureCard(
                    icon: Icons.storefront_outlined,
                    iconColor: isGhoul ? colors.accentSecondary : colors.successText,
                    title: '附近觅食',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.nearby),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FeatureCard(
                    icon: Icons.map_outlined,
                    iconColor: colors.infoText,
                    title: '地图选店',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.restaurantMap),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FeatureCard(
                    icon: Icons.casino_outlined,
                    iconColor: colors.accent,
                    title: '随机吃什么',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.randomEat),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FeatureCard(
                    icon: Icons.bookmark_outline,
                    iconColor: colors.warningText,
                    title: '想去清单',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.wantedRestaurants),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '在家做饭',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: colors.textPrimary),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FeatureCard(
                    icon: Icons.soup_kitchen_outlined,
                    iconColor: colors.warningText,
                    title: '烹饪模式',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.cookMode),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FeatureCard(
                    icon: Icons.menu_book_outlined,
                    iconColor: colors.infoText,
                    title: '菜品库',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.recipeLibrary),
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
