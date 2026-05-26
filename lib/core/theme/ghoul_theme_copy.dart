import 'package:soulfood_front/core/app_bootstrap.dart';
import 'package:soulfood_front/core/theme/app_theme_variant.dart';

/// 喰种主题专用文案；经典/深色暖色主题返回 [classic]。
String ghoulThemedText(String classic, {required String ghoul}) {
  if (AppServices.I.appearance.variant == AppThemeVariant.ghoul) return ghoul;
  return classic;
}

bool get isGhoulTheme => AppServices.I.appearance.variant == AppThemeVariant.ghoul;
