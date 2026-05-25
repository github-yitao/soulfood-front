import 'package:flutter/material.dart';
import 'package:soulfood_front/features/agent/agent_repository.dart';
import 'package:soulfood_front/features/favorite/favorite_repository.dart';
import 'package:soulfood_front/features/preference/preference_repository.dart';
import 'package:soulfood_front/features/room/room_models.dart';

/// 投票结果 + AI 菜谱推荐
class RecipeResultPage extends StatefulWidget {
  const RecipeResultPage({
    super.key,
    required this.voteResult,
    this.roomCode,
    this.preference,
  });

  final RoomResult voteResult;
  final String? roomCode;
  final String? preference;

  @override
  State<RecipeResultPage> createState() => _RecipeResultPageState();
}

class _RecipeResultPageState extends State<RecipeResultPage> {
  final _agent = AgentRepository();
  final _prefRepo = PreferenceRepository();
  final _favRepo = FavoriteRepository();
  List<RecipeItem> _recipes = [];
  bool _loadingRecipes = true;
  String? _error;
  String _preferenceText = '清淡、家常菜';
  final Set<String> _favorited = {};

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _loadingRecipes = true;
      _error = null;
    });
    try {
      final pref = widget.preference ?? await _prefRepo.preferenceText();
      _preferenceText = pref;
      final items = await _agent.recommendRecipes(
        preference: pref,
        voteWinner: widget.voteResult.title,
      );
      if (mounted) setState(() => _recipes = items);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loadingRecipes = false);
    }
  }

  Future<void> _favorite(RecipeItem item) async {
    if (_favorited.contains(item.name)) return;
    try {
      await _favRepo.addRecipe(
        title: item.name,
        reason: item.reason,
        score: item.score,
        category: '家常菜',
      );
      if (mounted) {
        setState(() => _favorited.add(item.name));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已收藏 ${item.name}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('推荐菜谱'),
        actions: [
          TextButton(
            onPressed: _loadingRecipes ? null : _loadRecipes,
            child: const Text('换一批'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFD79F)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFFD86A00), size: 18),
                    const SizedBox(width: 6),
                    const Text('投票胜出', style: TextStyle(color: Color(0xFF6F7888), fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.voteResult.title,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
                Text(
                  '${widget.voteResult.voteCount} 票 · ${widget.voteResult.percent}%'
                  '${widget.roomCode != null ? ' · 房间 ${widget.roomCode}' : ''}',
                  style: const TextStyle(color: Color(0xFFD86A00), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('AI 推荐菜谱', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            '偏好：$_preferenceText',
            style: const TextStyle(color: Color(0xFF8D919A), fontSize: 13),
          ),
          const SizedBox(height: 12),
          if (_loadingRecipes)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Text(_error!, style: const TextStyle(color: Color(0xFF8D919A))),
                  const SizedBox(height: 8),
                  OutlinedButton(onPressed: _loadRecipes, child: const Text('重试')),
                ],
              ),
            )
          else
            ..._recipes.map(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFFFEFBC),
                    child: Text(
                      item.name.isNotEmpty ? item.name.substring(0, 1) : '?',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(item.reason, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${item.score}分'),
                      IconButton(
                        icon: Icon(
                          _favorited.contains(item.name) ? Icons.favorite : Icons.favorite_border,
                          color: const Color(0xFFFF7A22),
                        ),
                        onPressed: () => _favorite(item),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: const Color(0xFFFF8A43),
            ),
            child: const Text('返回首页'),
          ),
        ],
      ),
    );
  }
}
