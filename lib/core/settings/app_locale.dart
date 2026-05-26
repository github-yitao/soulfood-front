enum AppLocale {
  zh,
  en;

  String get languageCode => switch (this) {
        AppLocale.zh => 'zh',
        AppLocale.en => 'en',
      };

  static AppLocale fromCode(String? code) => switch (code) {
        'en' => AppLocale.en,
        _ => AppLocale.zh,
      };
}

enum AppIconVariant {
  classic,
  ghoul;

  /// 传给 flutter_dynamic_icon_plus 的名称；null 表示默认图标。
  String? get pluginIconName => switch (this) {
        AppIconVariant.classic => null,
        AppIconVariant.ghoul => 'icon_ghoul',
      };
}
