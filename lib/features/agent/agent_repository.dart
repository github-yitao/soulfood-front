import 'package:soulfood_front/core/app_bootstrap.dart';

class RecipeItem {
  RecipeItem({required this.name, required this.score, this.reason = ''});

  final String name;
  final String score;
  final String reason;
}

class AgentRepository {
  AgentRepository() : _api = AppServices.I.api;

  final dynamic _api;

  Future<List<RecipeItem>> recommend({String preference = '清淡、家常菜'}) async {
    final text = await _api.getPlain(
      '/ai/recommend',
      query: {'preference': preference},
    );
    return _parseRecipes(text);
  }

  List<RecipeItem> _parseRecipes(String text) {
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) {
      return [
        RecipeItem(name: '番茄炒蛋', score: '4.8', reason: '演示数据'),
        RecipeItem(name: '土豆丝炒肉', score: '4.6', reason: '演示数据'),
      ];
    }
    return lines.take(5).map((line) {
      final cleaned = line.replaceAll(RegExp(r'^[\d\.\)、\-\*•\s]+'), '').trim();
      final scoreMatch = RegExp(r'(\d\.\d)').firstMatch(line);
      return RecipeItem(
        name: cleaned.split(RegExp(r'[：:]')).first.trim().substring(
              0,
              cleaned.length.clamp(0, 20),
            ),
        score: scoreMatch?.group(1) ?? '4.5',
        reason: cleaned,
      );
    }).toList();
  }
}
