import 'package:soulfood_front/core/api/api_client.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';

class RestaurantItem {
  RestaurantItem({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.distanceKm,
    required this.wanted,
    required this.favorited,
  });

  final int id;
  final String name;
  final String category;
  final double? rating;
  final double? distanceKm;
  final bool wanted;
  final bool favorited;

  factory RestaurantItem.fromJson(Map<String, dynamic> json) {
    return RestaurantItem(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      wanted: json['wanted'] as bool? ?? false,
      favorited: json['favorited'] as bool? ?? false,
    );
  }
}

class NearbyRepository {
  NearbyRepository() : _api = AppServices.I.api;

  final ApiClient _api;

  Future<List<RestaurantItem>> list({String? category, String? keyword}) async {
    return _api.getData<List<RestaurantItem>>(
      '/api/v1/restaurants/nearby',
      query: {
        if (category != null && category.isNotEmpty) 'category': category,
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      },
      parser: (json) => (json as List<dynamic>)
          .map((e) => RestaurantItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<void> markWant(int restaurantId) async {
    await _api.postVoid('/api/v1/restaurants/$restaurantId/want');
  }
}
