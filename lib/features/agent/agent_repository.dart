import 'package:soulfood_front/core/api/api_client.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';

class RecipeItem {
  RecipeItem({required this.name, required this.score, this.reason = ''});

  final String name;
  final String score;
  final String reason;

  factory RecipeItem.fromJson(Map<String, dynamic> json) {
    return RecipeItem(
      name: json['name'] as String? ?? '',
      score: (json['score'] as num?)?.toString() ?? '4.5',
      reason: json['reason'] as String? ?? '',
    );
  }
}

class RandomPickResult {
  RandomPickResult({required this.name, required this.reason});

  final String name;
  final String reason;

  factory RandomPickResult.fromJson(Map<String, dynamic> json) {
    return RandomPickResult(
      name: json['name'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }
}

class AgentRepository {
  AgentRepository() : _api = AppServices.I.api;

  final ApiClient _api;

  Future<List<RecipeItem>> recommendRecipes({
    String preference = '清淡、家常菜',
    String? voteWinner,
    int? participants,
  }) async {
    try {
      final data = await _api.postData<Map<String, dynamic>>(
        '/ai/recommend/recipes',
        data: {
          'preference': preference,
          if (voteWinner != null && voteWinner.isNotEmpty) 'voteWinner': voteWinner,
          if (participants != null) 'participants': participants,
        },
        parser: (json) => json as Map<String, dynamic>,
      );
      final items = data['items'] as List<dynamic>? ?? [];
      if (items.isNotEmpty) {
        return items
            .map((e) => RecipeItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      final raw = data['rawReply'] as String? ?? '';
      final parsed = _parseRecipesFromText(raw);
      if (parsed.isNotEmpty) return parsed;
    } catch (_) {
      // fallback below
    }
    return _fallbackRecipes(voteWinner);
  }

  List<RecipeItem> _fallbackRecipes(String? voteWinner) {
    if (voteWinner != null && voteWinner.contains('火锅')) {
      return [
        RecipeItem(name: '毛肚', score: '4.8', reason: '火锅经典（离线推荐）'),
        RecipeItem(name: '肥牛卷', score: '4.7', reason: '搭配火锅很合适'),
        RecipeItem(name: '娃娃菜', score: '4.6', reason: '解腻必备'),
      ];
    }
    return [
      RecipeItem(name: '番茄炒蛋', score: '4.8', reason: '清淡下饭（离线推荐）'),
      RecipeItem(name: '土豆丝炒肉', score: '4.6', reason: '家常菜'),
      RecipeItem(name: '青菜鸡蛋面', score: '4.7', reason: '快手暖胃'),
    ];
  }

  Future<List<String>> suggestOptions({
    required String topic,
    List<String> existingOptions = const [],
  }) async {
    final data = await _api.postData<Map<String, dynamic>>(
      '/ai/suggest-options',
      data: {
        'topic': topic,
        'existingOptions': existingOptions,
      },
      parser: (json) => json as Map<String, dynamic>,
    );
    final options = data['options'] as List<dynamic>? ?? [];
    return options.map((e) => '$e').where((s) => s.length >= 2).take(4).toList();
  }

  Future<RandomPickResult> randomPick({
    required List<String> candidates,
    String preference = '',
  }) async {
    return _api.postData<RandomPickResult>(
      '/ai/random-pick',
      data: {
        'candidates': candidates,
        if (preference.isNotEmpty) 'preference': preference,
      },
      parser: (json) => RandomPickResult.fromJson(json as Map<String, dynamic>),
    );
  }

  List<RecipeItem> _parseRecipesFromText(String text) {
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) {
      return [
        RecipeItem(name: '番茄炒蛋', score: '4.8', reason: '演示推荐'),
        RecipeItem(name: '土豆丝炒肉', score: '4.6', reason: '演示推荐'),
      ];
    }
    return lines.take(5).map((line) {
      final scoreMatch = RegExp(r'(\d\.\d)').firstMatch(line);
      var name = line.replaceAll(RegExp(r'^[\d\.\)、\-\*•\s]+'), '').trim();
      final colon = name.contains('：') ? name.indexOf('：') : name.indexOf(':');
      var reason = '';
      if (colon > 0) {
        reason = name.substring(colon + 1).trim();
        name = name.substring(0, colon).trim();
      }
      if (name.length > 20) name = name.substring(0, 20);
      return RecipeItem(
        name: name.isEmpty ? '推荐菜' : name,
        score: scoreMatch?.group(1) ?? '4.5',
        reason: reason.isEmpty ? line : reason,
      );
    }).toList();
  }
}
