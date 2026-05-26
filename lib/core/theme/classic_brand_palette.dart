import 'package:flutter/material.dart';

/// 经典暖色主题品牌色（与 App 图标、启动页、Hero 圆环一致）。
abstract final class ClassicBrandPalette {
  static const gold = Color(0xFFF6CF57);
  static const cream = Color(0xFFFFF4D6);
  static const peach = Color(0xFFFFB347);
  static const accent = Color(0xFFFF8A43);
  static const accentDeep = Color(0xFFD86A00);
  static const bowl = Color(0xFFFF8A43);
  static const chopstick = Color(0xFFD28A3C);
  static const plate = Color(0xFFFFFFF0);
  static const scaffoldLight = Color(0xFFFFFBF7);
  static const scaffoldDark = Color(0xFF14120F);
  static const steam = Color(0xFFFFE8C8);

  static const heroGradient = [cream, gold];
  static const heroGradientDark = [Color(0xFF4A3D28), Color(0xFF2E2618)];

  /// Android adaptive icon 背景（与 scripts/generate_app_icons.sh 一致）
  static const launcherBackground = Color(0xFFF6CF57);
}
