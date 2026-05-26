import 'package:flutter/material.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/core/theme/theme_widgets.dart';
import 'package:soulfood_front/features/agent/agent_repository.dart';
import 'package:soulfood_front/features/preference/preference_repository.dart';
import 'package:soulfood_front/l10n/app_localizations.dart';

class CookModePage extends StatefulWidget {
  const CookModePage({super.key});

  @override
  State<CookModePage> createState() => _CookModePageState();
}

class _CookModePageState extends State<CookModePage> {
  final _agent = AgentRepository();
  final _prefRepo = PreferenceRepository();

  static const _ingredients = [
    '鸡蛋', '番茄', '土豆', '鸡肉', '牛肉', '豆腐',
    '青椒', '洋葱', '面条', '米饭', '虾', '蘑菇',
  ];

  final Set<String> _selected = {};
  List<RecipeItem> _recipes = [];
  bool _loading = false;

  Future<void> _generate() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请至少选择一种食材')));
      return;
    }
    setState(() => _loading = true);
    try {
      final pref = await _prefRepo.preferenceText();
      final ingredientText = _selected.join('、');
      final items = await _agent.recommendRecipes(
        preference: '$pref；现有食材：$ingredientText；请优先用这些食材做菜',
        voteWinner: '在家做饭',
      );
      if (mounted) setState(() => _recipes = items);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cookModeTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '选选冰箱里有什么',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: colors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'AI 会根据食材和你的口味偏好，推荐可做的菜',
            style: TextStyle(fontSize: 13, color: colors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _ingredients.map((name) {
              final active = _selected.contains(name);
              return AppFilterChip(
                label: name,
                selected: active,
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _selected.add(name);
                    } else {
                      _selected.remove(name);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _loading ? null : _generate,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: _loading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.generateRecipe),
          ),
          if (_recipes.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('推荐菜谱', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 10),
            ..._recipes.map((item) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(item.reason),
                  trailing: Text('${item.score}分'),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
