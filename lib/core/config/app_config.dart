import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  /// 优先级：`--dart-define=API_BASE_URL=...` > 平台默认。
  ///
  /// 真机联调需隧道时：
  /// `flutter run --dart-define=API_BASE_URL=https://xxx.trycloudflare.com/soulfood`
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }
    // Android 模拟器访问宿主机；iOS 模拟器用 localhost。真机请用 dart-define。
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:8080/soulfood'
        : 'http://127.0.0.1:8080/soulfood';
  }

  static String get wsBaseUrl {
    final http = baseUrl;
    if (http.startsWith('https://')) {
      return http.replaceFirst('https://', 'wss://');
    }
    return http.replaceFirst('http://', 'ws://');
  }
}
