import 'package:flutter/material.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/core/theme/theme_widgets.dart';
import 'package:soulfood_front/features/favorite/favorite_repository.dart';
import 'package:soulfood_front/features/recipe/recipe_repository.dart';

class RecipeDetailPage extends StatefulWidget {
  const RecipeDetailPage({super.key, required this.recipeId});

  final int recipeId;

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  final _repo = RecipeRepository();
  final _favRepo = FavoriteRepository();
  RecipeDetail? _recipe;
  bool _loading = true;
  bool _favorited = false;
  bool _favBusy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final recipe = await _repo.getById(widget.recipeId);
      if (mounted) setState(() => _recipe = recipe);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleFavorite() async {
    final recipe = _recipe;
    if (recipe == null || _favBusy) return;
    setState(() => _favBusy = true);
    try {
      if (_favorited) {
        await _favRepo.removeRecipe(recipe.id);
        if (mounted) {
          setState(() => _favorited = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已取消收藏')));
        }
      } else {
        await _favRepo.addRecipe(
          recipeId: recipe.id,
          title: recipe.name,
          reason: recipe.summary,
          score: recipe.score.toString(),
          category: recipe.category,
          duration: '${recipe.durationMin} 分钟',
        );
        if (mounted) {
          setState(() => _favorited = true);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已收藏')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _favBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('菜谱详情')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final recipe = _recipe;
    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('菜谱详情')),
        body: const Center(child: Text('菜谱不存在')),
      );
    }

    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        actions: [
          IconButton(
            onPressed: _favBusy ? null : _toggleFavorite,
            icon: Icon(
              _favorited ? Icons.favorite : Icons.favorite_border,
              color: _favorited ? colors.accent : null,
            ),
            tooltip: _favorited ? '取消收藏' : '收藏菜谱',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: appCardDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${recipe.category} · ${recipe.difficulty} · ${recipe.durationMin} 分钟 · 评分 ${recipe.score}',
                  style: TextStyle(color: colors.textSecondary, fontSize: 13),
                ),
                if (recipe.summary != null && recipe.summary!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(recipe.summary!, style: const TextStyle(height: 1.5)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('食材', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...recipe.ingredients.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: colors.accent)),
                  Expanded(child: Text(item)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('步骤', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...recipe.steps.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: colors.chipSelectedBackground,
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(entry.value, style: const TextStyle(height: 1.45))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
