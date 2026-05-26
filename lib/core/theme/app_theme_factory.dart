import 'package:flutter/material.dart';
import 'package:soulfood_front/core/settings/appearance_store.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/core/theme/app_theme_variant.dart';
import 'package:soulfood_front/core/theme/classic_brand_palette.dart';

class AppThemeFactory {
  AppThemeFactory._();

  static const _fontFamily = 'PingFang SC';

  static ThemeData classicLight() => _build(
        brightness: Brightness.light,
        semantic: AppSemanticColors.classicLight,
        scaffold: ClassicBrandPalette.scaffoldLight,
        seed: ClassicBrandPalette.gold,
      );

  static ThemeData classicDark() => _build(
        brightness: Brightness.dark,
        semantic: AppSemanticColors.classicDark,
        scaffold: ClassicBrandPalette.scaffoldDark,
        seed: ClassicBrandPalette.gold,
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
      chipTheme: ChipThemeData(
        backgroundColor: semantic.chipBackground,
        selectedColor: semantic.chipSelectedBackground,
        disabledColor: semantic.chipBackground.withValues(alpha: 0.5),
        labelStyle: TextStyle(color: semantic.chipText, fontWeight: FontWeight.w600),
        secondaryLabelStyle: TextStyle(color: semantic.chipSelectedText, fontWeight: FontWeight.w700),
        side: BorderSide(color: semantic.chipBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        checkmarkColor: semantic.chipSelectedText,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: semantic.sliderActive,
        thumbColor: semantic.sliderActive,
        inactiveTrackColor: semantic.chipBorder,
        overlayColor: semantic.sliderActive.withValues(alpha: 0.12),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return semantic.accent;
          return semantic.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return semantic.accent.withValues(alpha: 0.35);
          }
          return semantic.chipBorder;
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: semantic.cardBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: semantic.cardBorder),
        ),
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: semantic.textPrimary,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: semantic.cardBackground,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: semantic.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: semantic.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: semantic.inputBorder),
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
      textTheme: isGhoul
          ? TextTheme(
              displayLarge: TextStyle(
                color: semantic.textPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
              displayMedium: TextStyle(
                color: semantic.textPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
              headlineMedium: TextStyle(
                color: semantic.textPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
              titleLarge: TextStyle(
                color: semantic.textPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
              titleMedium: TextStyle(
                color: semantic.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              bodyLarge: TextStyle(color: semantic.textPrimary, height: 1.45),
              bodyMedium: TextStyle(color: semantic.textPrimary, height: 1.4),
              bodySmall: TextStyle(color: semantic.textSecondary, height: 1.35),
              labelLarge: TextStyle(
                color: semantic.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.15,
              ),
              labelMedium: TextStyle(color: semantic.textSecondary),
              labelSmall: TextStyle(color: semantic.offline, fontSize: 11),
            )
          : null,
    );
  }
}
