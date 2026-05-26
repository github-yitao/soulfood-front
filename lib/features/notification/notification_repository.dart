import 'package:soulfood_front/core/api/api_client.dart';

class AppNotification {
  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.roomCode,
    required this.read,
    required this.createdAt,
  });

  final int id;
  final String type;
  final String title;
  final String body;
  final String? roomCode;
  final bool read;
  final String createdAt;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      roomCode: json['roomCode'] as String?,
      read: json['read'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

class NotificationOverview {
  NotificationOverview({required this.unreadCount, required this.items});

  final int unreadCount;
  final List<AppNotification> items;

  factory NotificationOverview.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return NotificationOverview(
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      items: rawItems
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class NotificationRepository {
  NotificationRepository(this._api);

  final ApiClient _api;
  static const Duration _cacheTtl = Duration(seconds: 45);
  static NotificationOverview? _cache;
  static DateTime? _cacheAt;

  NotificationOverview? readCache() {
    final data = _cache;
    final at = _cacheAt;
    if (data == null || at == null) return null;
    if (DateTime.now().difference(at) > _cacheTtl) return null;
    return data;
  }

  Future<NotificationOverview> load() async {
    final data = await _api.getData(
      '/api/v1/notifications',
      parser: (json) =>
          NotificationOverview.fromJson(json as Map<String, dynamic>),
    );
    _cache = data;
    _cacheAt = DateTime.now();
    return data;
  }

  Future<void> markRead(int id) async {
    await _api.patchVoid('/api/v1/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await _api.postVoid('/api/v1/notifications/read-all');
    _cache = null;
    _cacheAt = null;
  }
}
