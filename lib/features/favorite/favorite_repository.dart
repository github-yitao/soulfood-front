import 'package:soulfood_front/core/api/api_client.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';

class FavoriteItem {
  FavoriteItem({
    required this.id,
    required this.targetType,
    required this.title,
    this.subtitle,
    this.category,
    this.score,
    this.duration,
  });

  final int id;
  final String targetType;
  final String title;
  final String? subtitle;
  final String? category;
  final String? score;
  final String? duration;

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: (json['id'] as num).toInt(),
      targetType: json['targetType'] as String? ?? 'recipe',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      category: json['category'] as String?,
      score: json['score'] as String?,
      duration: json['duration'] as String?,
    );
  }
}

class FavoriteRepository {
  FavoriteRepository() : _api = AppServices.I.api;

  final ApiClient _api;

  Future<List<FavoriteItem>> list({String? type}) async {
    final data = await _api.getData<List<dynamic>>(
      '/api/v1/favorites',
      query: type == null ? null : {'type': type},
      parser: (json) => json as List<dynamic>,
    );
    return data
        .map((e) => FavoriteItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<FavoriteItem> addRecipe({
    required String title,
    String? reason,
    String? score,
    String? category,
    String? duration,
  }) async {
    final data = await _api.postData<Map<String, dynamic>>(
      '/api/v1/favorites',
      data: {
        'targetType': 'recipe',
        'title': title,
        if (reason != null) 'subtitle': reason,
        if (score != null) 'score': score,
        if (category != null) 'category': category,
        if (duration != null) 'duration': duration,
      },
      parser: (json) => json as Map<String, dynamic>,
    );
    return FavoriteItem.fromJson(data);
  }

  Future<FavoriteItem> addRestaurant({
    required int restaurantId,
    required String title,
    String? subtitle,
    String? category,
    String? score,
  }) async {
    final data = await _api.postData<Map<String, dynamic>>(
      '/api/v1/favorites',
      data: {
        'targetType': 'restaurant',
        'targetId': restaurantId,
        'title': title,
        if (subtitle != null) 'subtitle': subtitle,
        if (category != null) 'category': category,
        if (score != null) 'score': score,
      },
      parser: (json) => json as Map<String, dynamic>,
    );
    return FavoriteItem.fromJson(data);
  }

  Future<void> remove(int id) async {
    await _api.deleteVoid('/api/v1/favorites/$id');
  }

  Future<void> removeRestaurant(int restaurantId) async {
    await _api.deleteVoid('/api/v1/favorites/target/restaurant/$restaurantId');
  }
}
