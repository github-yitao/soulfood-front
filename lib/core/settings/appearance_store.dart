import 'package:shared_preferences/shared_preferences.dart';
import 'package:soulfood_front/core/theme/app_theme_variant.dart';

enum AppThemeMode { light, dark, system }

class AppearanceSettings {
  const AppearanceSettings({
    required this.variant,
    required this.mode,
  });

  final AppThemeVariant variant;
  final AppThemeMode mode;

  static const defaults = AppearanceSettings(
    variant: AppThemeVariant.classic,
    mode: AppThemeMode.system,
  );
}

class AppearanceStore {
  static const _keyThemeMode = 'theme_mode';
  static const _keyThemeVariant = 'theme_variant';

  AppearanceSettings _settings = AppearanceSettings.defaults;

  AppearanceSettings get settings => _settings;

  AppThemeMode get mode => _settings.mode;

  AppThemeVariant get variant => _settings.variant;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawMode = prefs.getString(_keyThemeMode);
    final rawVariant = prefs.getString(_keyThemeVariant);

    final mode = switch (rawMode) {
      'light' => AppThemeMode.light,
      'dark' => AppThemeMode.dark,
      _ => AppThemeMode.system,
    };

    final variant = switch (rawVariant) {
      'ghoul' => AppThemeVariant.ghoul,
      _ => AppThemeVariant.classic,
    };

    _settings = AppearanceSettings(variant: variant, mode: mode);
  }

  Future<void> saveMode(AppThemeMode mode) async {
    _settings = AppearanceSettings(variant: _settings.variant, mode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode.name);
  }

  Future<void> saveVariant(AppThemeVariant variant) async {
    _settings = AppearanceSettings(variant: variant, mode: _settings.mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeVariant, variant.name);
  }

  Future<void> save(AppearanceSettings settings) async {
    _settings = settings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, settings.mode.name);
    await prefs.setString(_keyThemeVariant, settings.variant.name);
  }
}
