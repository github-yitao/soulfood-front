import 'package:soulfood_front/core/api/api_client.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';

class RecipeSummary {
  RecipeSummary({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.durationMin,
    required this.score,
    this.summary,
  });

  final int id;
  final String name;
  final String category;
  final String difficulty;
  final int durationMin;
  final double score;
  final String? summary;

  factory RecipeSummary.fromJson(Map<String, dynamic> json) {
    return RecipeSummary(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? '简单',
      durationMin: (json['durationMin'] as num?)?.toInt() ?? 30,
      score: (json['score'] as num?)?.toDouble() ?? 4.5,
      summary: json['summary'] as String?,
    );
  }
}

class RecipeDetail {
  RecipeDetail({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.durationMin,
    required this.score,
    this.summary,
    required this.ingredients,
    required this.steps,
  });

  final int id;
  final String name;
  final String category;
  final String difficulty;
  final int durationMin;
  final double score;
  final String? summary;
  final List<String> ingredients;
  final List<String> steps;

  factory RecipeDetail.fromJson(Map<String, dynamic> json) {
    return RecipeDetail(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? '简单',
      durationMin: (json['durationMin'] as num?)?.toInt() ?? 30,
      score: (json['score'] as num?)?.toDouble() ?? 4.5,
      summary: json['summary'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>? ?? [])
          .map((e) => '$e')
          .toList(),
      steps: (json['steps'] as List<dynamic>? ?? []).map((e) => '$e').toList(),
    );
  }
}

class RecipeRepository {
  RecipeRepository() : _api = AppServices.I.api;

  final ApiClient _api;

  Future<List<RecipeSummary>> list({String? category, String? keyword}) async {
    return _api.getData<List<RecipeSummary>>(
      '/api/v1/recipes',
      query: {
        if (category != null && category.isNotEmpty) 'category': category,
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      },
      parser: (json) => (json as List<dynamic>)
          .map((e) => RecipeSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<RecipeDetail> getById(int id) async {
    return _api.getData<RecipeDetail>(
      '/api/v1/recipes/$id',
      parser: (json) => RecipeDetail.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<RecipeDetail> findByName(String name) async {
    return _api.getData<RecipeDetail>(
      '/api/v1/recipes/by-name',
      query: {'name': name},
      parser: (json) => RecipeDetail.fromJson(json as Map<String, dynamic>),
    );
  }
}
