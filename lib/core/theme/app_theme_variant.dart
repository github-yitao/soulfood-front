enum AppThemeVariant {
  classic,
  ghoul,
}

extension AppThemeVariantX on AppThemeVariant {
  String get label => switch (this) {
        AppThemeVariant.classic => '经典暖色',
        AppThemeVariant.ghoul => '喰种暗红',
      };

  String get description => switch (this) {
        AppThemeVariant.classic => '明亮轻快，适合日常选餐',
        AppThemeVariant.ghoul => '暗色高对比，灵感来自东京喰种',
      };
}
