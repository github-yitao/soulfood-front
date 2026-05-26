import 'package:flutter/material.dart';
import 'package:soulfood_front/core/settings/appearance_store.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/core/theme/app_theme_variant.dart';

class AppThemeFactory {
  AppThemeFactory._();

  static const _fontFamily = 'PingFang SC';

  static ThemeData classicLight() => _build(
        brightness: Brightness.light,
        semantic: AppSemanticColors.classicLight,
        scaffold: const Color(0xFFF5F6F8),
        seed: const Color(0xFFFFD966),
      );

  static ThemeData classicDark() => _build(
        brightness: Brightness.dark,
        semantic: AppSemanticColors.classicDark,
        scaffold: const Color(0xFF121316),
        seed: const Color(0xFFFFD966),
      );

  static ThemeData ghoul() => _build(
        brightness: Brightness.dark,
        semantic: AppSemanticColors.ghoul,
        scaffold: const Color(0xFF1C1C1E),
        seed: const Color(0xFFFF3B30),
        isGhoul: true,
      );

  static ThemeData resolve(AppearanceSettings settings, Brightness platformBrightness) {
    if (settings.variant == AppThemeVariant.ghoul) {
      return ghoul();
    }
    final useDark = switch (settings.mode) {
      AppThemeMode.light => false,
      AppThemeMode.dark => true,
      AppThemeMode.system => platformBrightness == Brightness.dark,
    };
    return useDark ? classicDark() : classicLight();
  }

  static ThemeData _build({
    required Brightness brightness,
    required AppSemanticColors semantic,
    required Color scaffold,
    required Color seed,
    bool isGhoul = false,
  }) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      primary: semantic.accent,
      surface: semantic.cardBackground,
    );

    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(20));

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: scaffold,
      colorScheme: colorScheme,
      extensions: [semantic],
      appBarTheme: AppBarTheme(
        backgroundColor: isGhoul ? const Color(0xFF1C1C1E) : scaffold,
        foregroundColor: semantic.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: semantic.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: semantic.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: semantic.cardBorder),
        ),
      ),
      dividerTheme: DividerThemeData(color: semantic.cardBorder, thickness: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: semantic.navBackground,
        indicatorColor: semantic.navIndicator,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? semantic.accent : semantic.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? semantic.accent : semantic.textSecondary,
            size: 24,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: semantic.accent,
          foregroundColor: isGhoul ? Colors.white : (isDark ? Colors.white : const Color(0xFF1E1F23)),
          shape: buttonShape,
          minimumSize: const Size.fromHeight(48),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: semantic.accent,
          side: BorderSide(color: semantic.accent),
          shape: buttonShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: semantic.textSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: semantic.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: semantic.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: semantic.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: semantic.accent, width: 1.5),
        ),
        labelStyle: TextStyle(color: semantic.textSecondary),
        hintStyle: TextStyle(color: semantic.textSecondary.withValues(alpha: 0.7)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: isGhoul ? const Color(0xFF252528) : null,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: semantic.accent),
      listTileTheme: ListTileThemeData(
        iconColor: semantic.textPrimary,
        textColor: semantic.textPrimary,
      ),
    );
  }
}
