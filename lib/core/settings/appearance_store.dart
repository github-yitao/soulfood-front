import 'package:shared_preferences/shared_preferences.dart';
import 'package:soulfood_front/core/settings/app_locale.dart';
import 'package:soulfood_front/core/theme/app_theme_variant.dart';

enum AppThemeMode { light, dark, system }

class AppearanceSettings {
  const AppearanceSettings({
    required this.variant,
    required this.mode,
    required this.locale,
    required this.appIcon,
  });

  final AppThemeVariant variant;
  final AppThemeMode mode;
  final AppLocale locale;
  final AppIconVariant appIcon;

  static const defaults = AppearanceSettings(
    variant: AppThemeVariant.classic,
    mode: AppThemeMode.system,
    locale: AppLocale.zh,
    appIcon: AppIconVariant.classic,
  );

  AppearanceSettings copyWith({
    AppThemeVariant? variant,
    AppThemeMode? mode,
    AppLocale? locale,
    AppIconVariant? appIcon,
  }) {
    return AppearanceSettings(
      variant: variant ?? this.variant,
      mode: mode ?? this.mode,
      locale: locale ?? this.locale,
      appIcon: appIcon ?? this.appIcon,
    );
  }
}

class AppearanceStore {
  static const _keyThemeMode = 'theme_mode';
  static const _keyThemeVariant = 'theme_variant';
  static const _keyLocale = 'app_locale';
  static const _keyAppIcon = 'app_icon';

  AppearanceSettings _settings = AppearanceSettings.defaults;

  AppearanceSettings get settings => _settings;

  AppThemeMode get mode => _settings.mode;

  AppThemeVariant get variant => _settings.variant;

  AppLocale get locale => _settings.locale;

  AppIconVariant get appIcon => _settings.appIcon;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawMode = prefs.getString(_keyThemeMode);
    final rawVariant = prefs.getString(_keyThemeVariant);
    final rawLocale = prefs.getString(_keyLocale);
    final rawIcon = prefs.getString(_keyAppIcon);

    final mode = switch (rawMode) {
      'light' => AppThemeMode.light,
      'dark' => AppThemeMode.dark,
      _ => AppThemeMode.system,
    };

    final variant = switch (rawVariant) {
      'ghoul' => AppThemeVariant.ghoul,
      _ => AppThemeVariant.classic,
    };

    _settings = AppearanceSettings(
      variant: variant,
      mode: mode,
      locale: AppLocale.fromCode(rawLocale),
      appIcon: switch (rawIcon) {
        'ghoul' => AppIconVariant.ghoul,
        _ => AppIconVariant.classic,
      },
    );
  }

  Future<void> saveMode(AppThemeMode mode) async {
    _settings = _settings.copyWith(mode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode.name);
  }

  Future<void> saveVariant(AppThemeVariant variant) async {
    _settings = _settings.copyWith(variant: variant);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeVariant, variant.name);
  }

  Future<void> saveLocale(AppLocale locale) async {
    _settings = _settings.copyWith(locale: locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, locale.languageCode);
  }

  Future<void> saveAppIcon(AppIconVariant icon) async {
    _settings = _settings.copyWith(appIcon: icon);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAppIcon, icon.name);
  }

  Future<void> save(AppearanceSettings settings) async {
    _settings = settings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, settings.mode.name);
    await prefs.setString(_keyThemeVariant, settings.variant.name);
    await prefs.setString(_keyLocale, settings.locale.languageCode);
    await prefs.setString(_keyAppIcon, settings.appIcon.name);
  }
}
