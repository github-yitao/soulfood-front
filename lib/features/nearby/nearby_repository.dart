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
    this.address,
    this.lat,
    this.lng,
    this.phone,
    this.photoUrl,
  });

  final int id;
  final String name;
  final String category;
  final double? rating;
  final double? distanceKm;
  final bool wanted;
  final bool favorited;
  final String? address;
  final double? lat;
  final double? lng;
  final String? phone;
  final String? photoUrl;

  factory RestaurantItem.fromJson(Map<String, dynamic> json) {
    return RestaurantItem(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      wanted: json['wanted'] as bool? ?? false,
      favorited: json['favorited'] as bool? ?? false,
      address: json['address'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      phone: json['phone'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }
}

class NearbyRepository {
  NearbyRepository() : _api = AppServices.I.api;

  final ApiClient _api;

  Future<List<RestaurantItem>> list({
    double? lat,
    double? lng,
    String? category,
    String? keyword,
  }) async {
    return _api.getData<List<RestaurantItem>>(
      '/api/v1/restaurants/nearby',
      query: {
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
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

  Future<List<RestaurantItem>> listWanted() async {
    return _api.getData(
      '/api/v1/restaurants/wanted',
      parser: (json) => (json as List<dynamic>)
          .map((e) => RestaurantItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<void> removeWant(int restaurantId) async {
    await _api.deleteVoid('/api/v1/restaurants/$restaurantId/want');
  }

  Future<RestaurantItem> getById(int restaurantId) async {
    return _api.getData<RestaurantItem>(
      '/api/v1/restaurants/$restaurantId',
      parser: (json) => RestaurantItem.fromJson(json as Map<String, dynamic>),
    );
  }
}
