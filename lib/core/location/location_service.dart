import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class UserLocation {
  const UserLocation({required this.lat, required this.lng});

  final double lat;
  final double lng;
}

class LocationService {
  /// 获取当前位置；权限未开、服务不可用或模拟器取不到点时返回 null
  static Future<UserLocation?> current() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    Position? lastKnown;
    try {
      lastKnown = await Geolocator.getLastKnownPosition();
    } catch (_) {}

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _settings(),
      );
      return UserLocation(lat: position.latitude, lng: position.longitude);
    } catch (_) {
      if (lastKnown != null) {
        return UserLocation(lat: lastKnown.latitude, lng: lastKnown.longitude);
      }
      return null;
    }
  }

  static LocationSettings _settings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 6),
        forceLocationManager: true,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.low,
      timeLimit: Duration(seconds: 6),
    );
  }
}
