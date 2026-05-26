import 'package:flutter/material.dart';

/// 应用语义色，供各页面读取以适配不同主题变体。
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.cardBackground,
    required this.cardBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.accentSecondary,
    required this.heroGradientStart,
    required this.heroGradientEnd,
    required this.heroText,
    required this.navBackground,
    required this.navIndicator,
    required this.featureDefaultBackground,
    required this.featureDefaultBorder,
    required this.featureDefaultText,
    required this.splashGlow,
  });

  final Color cardBackground;
  final Color cardBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final Color accentSecondary;
  final Color heroGradientStart;
  final Color heroGradientEnd;
  final Color heroText;
  final Color navBackground;
  final Color navIndicator;
  final Color featureDefaultBackground;
  final Color featureDefaultBorder;
  final Color featureDefaultText;
  final Color splashGlow;

  @override
  AppSemanticColors copyWith({
    Color? cardBackground,
    Color? cardBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? accent,
    Color? accentSecondary,
    Color? heroGradientStart,
    Color? heroGradientEnd,
    Color? heroText,
    Color? navBackground,
    Color? navIndicator,
    Color? featureDefaultBackground,
    Color? featureDefaultBorder,
    Color? featureDefaultText,
    Color? splashGlow,
  }) {
    return AppSemanticColors(
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      accent: accent ?? this.accent,
      accentSecondary: accentSecondary ?? this.accentSecondary,
      heroGradientStart: heroGradientStart ?? this.heroGradientStart,
      heroGradientEnd: heroGradientEnd ?? this.heroGradientEnd,
      heroText: heroText ?? this.heroText,
      navBackground: navBackground ?? this.navBackground,
      navIndicator: navIndicator ?? this.navIndicator,
      featureDefaultBackground: featureDefaultBackground ?? this.featureDefaultBackground,
      featureDefaultBorder: featureDefaultBorder ?? this.featureDefaultBorder,
      featureDefaultText: featureDefaultText ?? this.featureDefaultText,
      splashGlow: splashGlow ?? this.splashGlow,
    );
  }

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    return AppSemanticColors(
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSecondary: Color.lerp(accentSecondary, other.accentSecondary, t)!,
      heroGradientStart: Color.lerp(heroGradientStart, other.heroGradientStart, t)!,
      heroGradientEnd: Color.lerp(heroGradientEnd, other.heroGradientEnd, t)!,
      heroText: Color.lerp(heroText, other.heroText, t)!,
      navBackground: Color.lerp(navBackground, other.navBackground, t)!,
      navIndicator: Color.lerp(navIndicator, other.navIndicator, t)!,
      featureDefaultBackground: Color.lerp(featureDefaultBackground, other.featureDefaultBackground, t)!,
      featureDefaultBorder: Color.lerp(featureDefaultBorder, other.featureDefaultBorder, t)!,
      featureDefaultText: Color.lerp(featureDefaultText, other.featureDefaultText, t)!,
      splashGlow: Color.lerp(splashGlow, other.splashGlow, t)!,
    );
  }

  static const classicLight = AppSemanticColors(
    cardBackground: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFECEFF3),
    textPrimary: Color(0xFF1E1F23),
    textSecondary: Color(0xFF747B87),
    accent: Color(0xFFFF8A43),
    accentSecondary: Color(0xFFFFD966),
    heroGradientStart: Color(0xFFFBF0A8),
    heroGradientEnd: Color(0xFFF6CF57),
    heroText: Color(0xFF12151D),
    navBackground: Color(0xFFFFFFFF),
    navIndicator: Color(0xFFFFEAA5),
    featureDefaultBackground: Color(0xFFFFFFFF),
    featureDefaultBorder: Color(0xFFECEFF3),
    featureDefaultText: Color(0xFF232630),
    splashGlow: Color(0x40FF904B),
  );

  static const classicDark = AppSemanticColors(
    cardBackground: Color(0xFF2A2B30),
    cardBorder: Color(0xFF3A3B42),
    textPrimary: Color(0xFFF2F3F5),
    textSecondary: Color(0xFF9AA0AB),
    accent: Color(0xFFFF9F5A),
    accentSecondary: Color(0xFFFFD966),
    heroGradientStart: Color(0xFF4A4228),
    heroGradientEnd: Color(0xFF2E2818),
    heroText: Color(0xFFF5F5F5),
    navBackground: Color(0xFF1E1F23),
    navIndicator: Color(0xFF4A4228),
    featureDefaultBackground: Color(0xFF2A2B30),
    featureDefaultBorder: Color(0xFF3A3B42),
    featureDefaultText: Color(0xFFE8EAED),
    splashGlow: Color(0x40FF904B),
  );

  static const ghoul = AppSemanticColors(
    cardBackground: Color(0xFF252528),
    cardBorder: Color(0xFF4A4A48),
    textPrimary: Color(0xFFF5F5F5),
    textSecondary: Color(0xFF757575),
    accent: Color(0xFFFF3B30),
    accentSecondary: Color(0xFFC0C0C0),
    heroGradientStart: Color(0xFF1C1C1E),
    heroGradientEnd: Color(0xFF0A0A0B),
    heroText: Color(0xFFF5F5F5),
    navBackground: Color(0xFF1C1C1E),
    navIndicator: Color(0x33FF3B30),
    featureDefaultBackground: Color(0xFF252528),
    featureDefaultBorder: Color(0xFF4A4A48),
    featureDefaultText: Color(0xFFE6E6E6),
    splashGlow: Color(0x66FF3B30),
  );
}

extension AppSemanticColorsContext on BuildContext {
  AppSemanticColors get appColors =>
      Theme.of(this).extension<AppSemanticColors>() ?? AppSemanticColors.classicLight;
}
