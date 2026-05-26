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
    required this.chipBackground,
    required this.chipSelectedBackground,
    required this.chipBorder,
    required this.chipSelectedBorder,
    required this.chipText,
    required this.chipSelectedText,
    required this.inputFill,
    required this.inputBorder,
    required this.sliderActive,
    required this.bannerBackground,
    required this.bannerBorder,
    required this.bannerText,
    required this.inviteCardBackground,
    required this.inviteCardBorder,
    required this.successBackground,
    required this.successBorder,
    required this.successText,
    required this.errorBackground,
    required this.errorBorder,
    required this.errorText,
    required this.infoBackground,
    required this.infoBorder,
    required this.infoText,
    required this.warningBackground,
    required this.warningBorder,
    required this.warningText,
    required this.online,
    required this.offline,
    required this.onAccent,
    required this.progressTrack,
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
  final Color chipBackground;
  final Color chipSelectedBackground;
  final Color chipBorder;
  final Color chipSelectedBorder;
  final Color chipText;
  final Color chipSelectedText;
  final Color inputFill;
  final Color inputBorder;
  final Color sliderActive;
  final Color bannerBackground;
  final Color bannerBorder;
  final Color bannerText;
  final Color inviteCardBackground;
  final Color inviteCardBorder;
  final Color successBackground;
  final Color successBorder;
  final Color successText;
  final Color errorBackground;
  final Color errorBorder;
  final Color errorText;
  final Color infoBackground;
  final Color infoBorder;
  final Color infoText;
  final Color warningBackground;
  final Color warningBorder;
  final Color warningText;
  final Color online;
  final Color offline;
  final Color onAccent;
  final Color progressTrack;

  @override
  AppSemanticColors copyWith({Color? cardBackground}) => this;

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppSemanticColors(
      cardBackground: l(cardBackground, other.cardBackground),
      cardBorder: l(cardBorder, other.cardBorder),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      accent: l(accent, other.accent),
      accentSecondary: l(accentSecondary, other.accentSecondary),
      heroGradientStart: l(heroGradientStart, other.heroGradientStart),
      heroGradientEnd: l(heroGradientEnd, other.heroGradientEnd),
      heroText: l(heroText, other.heroText),
      navBackground: l(navBackground, other.navBackground),
      navIndicator: l(navIndicator, other.navIndicator),
      featureDefaultBackground: l(featureDefaultBackground, other.featureDefaultBackground),
      featureDefaultBorder: l(featureDefaultBorder, other.featureDefaultBorder),
      featureDefaultText: l(featureDefaultText, other.featureDefaultText),
      splashGlow: l(splashGlow, other.splashGlow),
      chipBackground: l(chipBackground, other.chipBackground),
      chipSelectedBackground: l(chipSelectedBackground, other.chipSelectedBackground),
      chipBorder: l(chipBorder, other.chipBorder),
      chipSelectedBorder: l(chipSelectedBorder, other.chipSelectedBorder),
      chipText: l(chipText, other.chipText),
      chipSelectedText: l(chipSelectedText, other.chipSelectedText),
      inputFill: l(inputFill, other.inputFill),
      inputBorder: l(inputBorder, other.inputBorder),
      sliderActive: l(sliderActive, other.sliderActive),
      bannerBackground: l(bannerBackground, other.bannerBackground),
      bannerBorder: l(bannerBorder, other.bannerBorder),
      bannerText: l(bannerText, other.bannerText),
      inviteCardBackground: l(inviteCardBackground, other.inviteCardBackground),
      inviteCardBorder: l(inviteCardBorder, other.inviteCardBorder),
      successBackground: l(successBackground, other.successBackground),
      successBorder: l(successBorder, other.successBorder),
      successText: l(successText, other.successText),
      errorBackground: l(errorBackground, other.errorBackground),
      errorBorder: l(errorBorder, other.errorBorder),
      errorText: l(errorText, other.errorText),
      infoBackground: l(infoBackground, other.infoBackground),
      infoBorder: l(infoBorder, other.infoBorder),
      infoText: l(infoText, other.infoText),
      warningBackground: l(warningBackground, other.warningBackground),
      warningBorder: l(warningBorder, other.warningBorder),
      warningText: l(warningText, other.warningText),
      online: l(online, other.online),
      offline: l(offline, other.offline),
      onAccent: l(onAccent, other.onAccent),
      progressTrack: l(progressTrack, other.progressTrack),
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
    chipBackground: Color(0xFFF7F9FC),
    chipSelectedBackground: Color(0xFFFFF2E0),
    chipBorder: Color(0xFFE8EDF4),
    chipSelectedBorder: Color(0xFFFFD79F),
    chipText: Color(0xFF5F697A),
    chipSelectedText: Color(0xFFD86A00),
    inputFill: Color(0xFFF8FAFD),
    inputBorder: Color(0xFFE9EDF4),
    sliderActive: Color(0xFFFF8D40),
    bannerBackground: Color(0xFFFFF8EB),
    bannerBorder: Color(0xFFFFE9A8),
    bannerText: Color(0xFF7A4B00),
    inviteCardBackground: Color(0xFFFFF8F2),
    inviteCardBorder: Color(0xFFFFD4B8),
    successBackground: Color(0xFFE8F5E9),
    successBorder: Color(0xFFB7DFC0),
    successText: Color(0xFF2E7D32),
    errorBackground: Color(0xFFFFF5F5),
    errorBorder: Color(0xFFFFD6D6),
    errorText: Color(0xFFB42318),
    infoBackground: Color(0xFFF0F7FF),
    infoBorder: Color(0xFFB8D4F0),
    infoText: Color(0xFF2B5EA8),
    warningBackground: Color(0xFFFFF4E8),
    warningBorder: Color(0xFFFFD79F),
    warningText: Color(0xFFD86A00),
    online: Color(0xFF2E7D32),
    offline: Color(0xFFB3B8C2),
    onAccent: Color(0xFFFFFFFF),
    progressTrack: Color(0xFFEFF2F6),
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
    chipBackground: Color(0xFF2A2B30),
    chipSelectedBackground: Color(0xFF4A4228),
    chipBorder: Color(0xFF3A3B42),
    chipSelectedBorder: Color(0xFFFF9F5A),
    chipText: Color(0xFF9AA0AB),
    chipSelectedText: Color(0xFFFFB347),
    inputFill: Color(0xFF2A2B30),
    inputBorder: Color(0xFF3A3B42),
    sliderActive: Color(0xFFFF9F5A),
    bannerBackground: Color(0xFF2A2B30),
    bannerBorder: Color(0xFF4A4228),
    bannerText: Color(0xFFFFB347),
    inviteCardBackground: Color(0xFF2A2B30),
    inviteCardBorder: Color(0xFF4A4228),
    successBackground: Color(0xFF1E3A24),
    successBorder: Color(0xFF2E7D32),
    successText: Color(0xFF81C784),
    errorBackground: Color(0xFF3A2020),
    errorBorder: Color(0xFF8B3A3A),
    errorText: Color(0xFFFF8A80),
    infoBackground: Color(0xFF1E2A3A),
    infoBorder: Color(0xFF3A5A8B),
    infoText: Color(0xFF90CAF9),
    warningBackground: Color(0xFF3A2E1E),
    warningBorder: Color(0xFF8B6914),
    warningText: Color(0xFFFFB347),
    online: Color(0xFF81C784),
    offline: Color(0xFF6B7078),
    onAccent: Color(0xFF1E1F23),
    progressTrack: Color(0xFF3A3B42),
  );

  static const ghoul = AppSemanticColors(
    cardBackground: Color(0xFF252528),
    cardBorder: Color(0xFF4A4A48),
    textPrimary: Color(0xFFF4ECEC),
    textSecondary: Color(0xFFB8A8A8),
    accent: Color(0xFFFF3B30),
    accentSecondary: Color(0xFFD4D4D4),
    heroGradientStart: Color(0xFF1C1C1E),
    heroGradientEnd: Color(0xFF0A0A0B),
    heroText: Color(0xFFFFF5F5),
    navBackground: Color(0xFF1C1C1E),
    navIndicator: Color(0x33FF3B30),
    featureDefaultBackground: Color(0xFF252528),
    featureDefaultBorder: Color(0xFF4A4A48),
    featureDefaultText: Color(0xFFE6DCDC),
    splashGlow: Color(0x66FF3B30),
    chipBackground: Color(0xFF252528),
    chipSelectedBackground: Color(0x33FF3B30),
    chipBorder: Color(0xFF4A4A48),
    chipSelectedBorder: Color(0xFFFF3B30),
    chipText: Color(0xFFA89494),
    chipSelectedText: Color(0xFFFF756D),
    inputFill: Color(0xFF252528),
    inputBorder: Color(0xFF4A4A48),
    sliderActive: Color(0xFFFF3B30),
    bannerBackground: Color(0xFF252528),
    bannerBorder: Color(0xFF4A4A48),
    bannerText: Color(0xFFFF8A82),
    inviteCardBackground: Color(0xFF1C1C1E),
    inviteCardBorder: Color(0xFF4A4A48),
    successBackground: Color(0xFF1A2E1A),
    successBorder: Color(0xFF2E5A2E),
    successText: Color(0xFF8FD98F),
    errorBackground: Color(0xFF3A1515),
    errorBorder: Color(0xFF8B2020),
    errorText: Color(0xFFFF8078),
    infoBackground: Color(0xFF221A1A),
    infoBorder: Color(0xFF5A4040),
    infoText: Color(0xFFD4A8A8),
    warningBackground: Color(0xFF2E1A1A),
    warningBorder: Color(0xFF8B3030),
    warningText: Color(0xFFFF9078),
    online: Color(0xFF8FD98F),
    offline: Color(0xFF8A7878),
    onAccent: Color(0xFFFFFFFF),
    progressTrack: Color(0xFF4A4A48),
  );
}

extension AppSemanticColorsContext on BuildContext {
  AppSemanticColors get appColors =>
      Theme.of(this).extension<AppSemanticColors>() ?? AppSemanticColors.classicLight;
}
