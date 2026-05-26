import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  /// 优先级：`--dart-define=API_BASE_URL=...` > 平台默认直连本机后端。
  ///
  /// 真机联调需隧道时：
  /// `flutter run --dart-define=API_BASE_URL=https://xxx.trycloudflare.com/soulfood`
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }
    if (kIsWeb) {
      return 'http://localhost:8080/soulfood';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8080/soulfood';
      default:
        return 'http://127.0.0.1:8080/soulfood';
    }
  }

  static String get wsBaseUrl {
    final http = baseUrl;
    if (http.startsWith('https://')) {
      return http.replaceFirst('https://', 'wss://');
    }
    return http.replaceFirst('http://', 'ws://');
  }
}
