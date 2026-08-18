import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dynamic_icon_plus/flutter_dynamic_icon_plus.dart';
import 'package:soulfood_front/core/settings/app_locale.dart';

class AppIconService {
  AppIconService._();

  static bool get _isIosSimulator {
    if (kIsWeb) return false;
    return Platform.isIOS &&
        Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');
  }

  static Future<bool> get isSupported async {
    if (kIsWeb || _isIosSimulator) return false;
    try {
      return await FlutterDynamicIconPlus.supportsAlternateIcons
          .timeout(const Duration(milliseconds: 800), onTimeout: () => false);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> apply(AppIconVariant variant) async {
    if (kIsWeb || _isIosSimulator) return false;
    try {
      final supported = await isSupported;
      if (!supported) return false;
      // isSilent: true 会走插件私有 API，且 iOS 实现不回调 Flutter result，
      // 导致 Future 永不结束、启动页一直转圈。
      await FlutterDynamicIconPlus.setAlternateIconName(
        iconName: variant.pluginIconName,
        blacklistBrands: const [],
        blacklistManufactures: const [],
        blacklistModels: const [],
        isSilent: false,
      ).timeout(const Duration(seconds: 3));
      return true;
    } catch (_) {
      return false;
    }
  }
}
