import 'package:flutter/foundation.dart';
import 'package:flutter_dynamic_icon_plus/flutter_dynamic_icon_plus.dart';
import 'package:soulfood_front/core/settings/app_locale.dart';

class AppIconService {
  AppIconService._();

  static Future<bool> get isSupported async {
    if (kIsWeb) return false;
    try {
      return await FlutterDynamicIconPlus.supportsAlternateIcons;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> apply(AppIconVariant variant) async {
    if (kIsWeb) return false;
    try {
      final supported = await isSupported;
      if (!supported) return false;
      await FlutterDynamicIconPlus.setAlternateIconName(
        iconName: variant.pluginIconName,
        blacklistBrands: const [],
        blacklistManufactures: const [],
        blacklistModels: const [],
        isSilent: true,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
