import 'package:soulfood_front/core/api/api_client.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';

class UserPreference {
  UserPreference({
    required this.tags,
    required this.spicyLevel,
    required this.sweetLevel,
    required this.noCoriander,
    required this.noPeanut,
    required this.allergens,
    required this.preferenceText,
  });

  final List<String> tags;
  final int spicyLevel;
  final int sweetLevel;
  final bool noCoriander;
  final bool noPeanut;
  final List<String> allergens;
  final String preferenceText;

  factory UserPreference.fromJson(Map<String, dynamic> json) {
    final tags = (json['tags'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    final allergens = (json['allergens'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    return UserPreference(
      tags: tags,
      spicyLevel: (json['spicyLevel'] as num?)?.toInt() ?? 3,
      sweetLevel: (json['sweetLevel'] as num?)?.toInt() ?? 2,
      noCoriander: json['noCoriander'] as bool? ?? false,
      noPeanut: json['noPeanut'] as bool? ?? false,
      allergens: allergens,
      preferenceText: json['preferenceText'] as String? ?? '清淡、家常菜',
    );
  }

  Map<String, dynamic> toJson() => {
        'tags': tags,
        'spicyLevel': spicyLevel,
        'sweetLevel': sweetLevel,
        'noCoriander': noCoriander,
        'noPeanut': noPeanut,
        'allergens': allergens,
      };
}

class PreferenceRepository {
  PreferenceRepository() : _api = AppServices.I.api;

  final ApiClient _api;
  UserPreference? _cache;

  Future<UserPreference> load() async {
    final data = await _api.getData<Map<String, dynamic>>(
      '/api/v1/users/me/preferences',
      parser: (json) => json as Map<String, dynamic>,
    );
    _cache = UserPreference.fromJson(data);
    return _cache!;
  }

  Future<UserPreference> save(UserPreference pref) async {
    final data = await _api.putData<Map<String, dynamic>>(
      '/api/v1/users/me/preferences',
      data: pref.toJson(),
      parser: (json) => json as Map<String, dynamic>,
    );
    _cache = UserPreference.fromJson(data);
    return _cache!;
  }

  Future<String> preferenceText() async {
    if (_cache != null) return _cache!.preferenceText;
    final pref = await load();
    return pref.preferenceText;
  }
}
