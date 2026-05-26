import 'package:soulfood_front/core/app_bootstrap.dart';
import 'package:soulfood_front/core/theme/app_theme_variant.dart';

bool get isClassicTheme => AppServices.I.appearance.variant == AppThemeVariant.classic;

/// 经典主题专用文案；喰种主题返回 [classic]。
String classicThemedText(String classic, {required String warm}) {
  if (AppServices.I.appearance.variant == AppThemeVariant.classic) return warm;
  return classic;
}
