import 'package:flutter/material.dart';
import 'package:soulfood_front/features/agent/agent_repository.dart';
import 'package:soulfood_front/features/favorite/favorite_repository.dart';
import 'package:soulfood_front/features/favorite/favorites_page.dart';
import 'package:soulfood_front/features/preference/preference_repository.dart';
import 'package:soulfood_front/features/room/room_models.dart';
import 'package:soulfood_front/features/room/widgets/vote_option_thumb.dart';

/// 投票结果 + AI 菜谱推荐（支持投票进行中预览）
class RecipeResultPage extends StatefulWidget {
  const RecipeResultPage({
    super.key,
    required this.voteResult,
    this.roomCode,
    this.preference,
    this.isPreview = false,
  });

  final RoomResult voteResult;
  final String? roomCode;
  final String? preference;
  /// 投票未结束时为 true，基于当前领先/已选项生成预览
  final bool isPreview;

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
  String _sourceLine = '';
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
      final result = await _agent.recommendRecipesDetailed(
        preference: pref,
        voteWinner: widget.voteResult.title,
      );
      if (mounted) {
        setState(() {
          _recipes = result.items;
          _sourceLine = result.fromApi
              ? '来源：POST /ai/recommend/recipes · AI 推荐'
              : '演示：后端未响应时使用本地推荐';
        });
      }
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

  Future<void> _favoriteAll() async {
    if (_recipes.isEmpty) return;
    var added = 0;
    for (final item in _recipes) {
      if (_favorited.contains(item.name)) continue;
      try {
        await _favRepo.addRecipe(
          title: item.name,
          reason: item.reason,
          score: item.score,
          category: '家常菜',
        );
        _favorited.add(item.name);
        added++;
      } catch (_) {
        // continue others
      }
    }
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(added > 0 ? '已收藏 $added 道菜' : '菜谱已在收藏中')),
    );
  }

  void _openFavorites() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const FavoritesPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final previewLabel = widget.isPreview ? '（预览）' : '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text('推荐菜谱$previewLabel'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (widget.isPreview)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCFE0FF)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Color(0xFF2B5EA8)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '投票进行中，菜谱基于当前选项预览；结束投票后可查看正式结果。',
                      style: TextStyle(fontSize: 13, color: Color(0xFF2B5EA8), height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8EB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFE9A8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF4D6), Color(0xFFFFE9A8)],
                    ),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFFFD79F)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, size: 14, color: Color(0xFFD86A00)),
                      SizedBox(width: 4),
                      Text(
                        'AI 推荐',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7A4B00),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    VoteOptionThumb(title: widget.voteResult.title),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isPreview ? '当前参考：${widget.voteResult.title}' : '投票胜出：${widget.voteResult.title}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E1F23),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.voteResult.voteCount} 票 · ${widget.voteResult.percent}%'
                            '${widget.roomCode != null ? ' · 房间 ${widget.roomCode}' : ''}',
                            style: const TextStyle(color: Color(0xFF8D919A), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.isPreview
                      ? '基于「${widget.voteResult.title}」与你的口味偏好（$_preferenceText）生成预览'
                      : '投票胜出：${widget.voteResult.title} · 已结合口味偏好（$_preferenceText）',
                  style: const TextStyle(color: Color(0xFF6F7888), fontSize: 13, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_loadingRecipes)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
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
              (item) => _RecipeCard(
                item: item,
                favorited: _favorited.contains(item.name),
                onFavorite: () => _favorite(item),
              ),
            ),
          if (_sourceLine.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _sourceLine,
              style: const TextStyle(fontSize: 11, color: Color(0xFF8D919A), height: 1.4),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _loadingRecipes ? null : _loadRecipes,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    foregroundColor: const Color(0xFF4D515A),
                  ),
                  child: const Text('换一批'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _recipes.isEmpty ? null : _favoriteAll,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    backgroundColor: const Color(0xFFFF8A43),
                  ),
                  child: const Text('收藏菜谱'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: _openFavorites,
              child: const Text('查看我的收藏'),
            ),
          ),
          if (!widget.isPreview) ...[
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: const Color(0xFF2B5EA8),
              ),
              child: const Text('返回首页'),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.item,
    required this.favorited,
    required this.onFavorite,
  });

  final RecipeItem item;
  final bool favorited;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFF2F6)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          VoteOptionThumb(title: item.name),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                if (item.reason.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.reason,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF8D919A), height: 1.35),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.score}分',
                style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFD86A00)),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                icon: Icon(
                  favorited ? Icons.favorite : Icons.favorite_border,
                  color: const Color(0xFFFF7A22),
                  size: 22,
                ),
                onPressed: favorited ? null : onFavorite,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
