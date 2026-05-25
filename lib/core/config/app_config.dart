class AppConfig {
  AppConfig._();

  /// Android 模拟器访问本机：10.0.2.2；真机请改局域网 IP
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/soulfood',
  );
}
