class AppConfig {
  AppConfig._();

  /// Cloudflare 隧道；本地可覆盖：flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/soulfood
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://wine-doug-broadcast-downloading.trycloudflare.com/soulfood',
  );
}
