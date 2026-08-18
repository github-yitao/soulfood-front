import 'dart:io';

import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  /// 优先级：`--dart-define=API_BASE_URL=...` > 平台默认。
  ///
  /// 当前默认隧道（2026-05-26）：
  /// `https://fever-arbitration-randy-assistant.trycloudflare.com/soulfood`
  ///
  /// 可通过 dart-define 覆盖：
  /// `flutter run --dart-define=API_BASE_URL=https://xxx.trycloudflare.com/soulfood`
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }
    // 默认走 Cloudflare 隧道，确保真机/模拟器可直接联调。
    // return 'https://prep-river-textile-colleague.trycloudflare.com/soulfood';
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8080/soulfood';
    }
    return 'http://127.0.0.1:8080/soulfood';
  }

  static String get wsBaseUrl {
    final http = baseUrl;
    if (http.startsWith('https://')) {
      return http.replaceFirst('https://', 'wss://');
    }
    return http.replaceFirst('http://', 'ws://');
  }
}
