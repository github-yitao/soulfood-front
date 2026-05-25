import 'package:flutter/material.dart';
import 'package:soulfood_front/features/favorite/ai_reply_detail_page.dart';
import 'package:soulfood_front/features/favorite/favorite_repository.dart';
import 'package:soulfood_front/features/nearby/restaurant_detail_page.dart';
import 'package:soulfood_front/features/recipe/recipe_detail_page.dart';
import 'package:soulfood_front/features/recipe/recipe_repository.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final _repo = FavoriteRepository();
  final _recipeRepo = RecipeRepository();
  static const _filters = [
    ('all', '全部'),
    ('recipe', '菜谱'),
    ('restaurant', '餐厅'),
    ('ai_reply', 'AI'),
  ];

  String _filter = 'all';
  List<FavoriteItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final type = _filter == 'all' ? null : _filter;
      final items = await _repo.list(type: type);
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _remove(FavoriteItem item) async {
    try {
      await _repo.remove(item.id);
      if (mounted) {
        setState(() => _items.removeWhere((e) => e.id == item.id));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _openItem(FavoriteItem item) async {
    try {
      switch (item.targetType) {
        case 'restaurant':
          if (item.targetId != null) {
            await Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (_) => RestaurantDetailPage(restaurantId: item.targetId!),
              ),
            );
          }
          break;
        case 'recipe':
          if (item.targetId != null) {
            await Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (_) => RecipeDetailPage(recipeId: item.targetId!),
              ),
            );
          } else {
            final detail = await _recipeRepo.findByName(item.title);
            if (!mounted) return;
            await Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (_) => RecipeDetailPage(recipeId: detail.id),
              ),
            );
          }
          break;
        case 'ai_reply':
          await Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (_) => AiReplyDetailPage(item: item),
            ),
          );
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  String _typeLabel(String type) {
    return switch (type) {
      'restaurant' => '餐厅',
      'ai_reply' => 'AI',
      _ => '菜谱',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的收藏')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: _filters.map((f) {
                final active = _filter == f.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f.$2),
                    selected: active,
                    onSelected: (_) {
                      setState(() => _filter = f.$1);
                      _load();
                    },
                    selectedColor: const Color(0xFFFFF2E0),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? const Center(
                        child: Text(
                          '暂无收藏\n在附近觅食、菜品库或 AI 对话中可添加收藏',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF8D919A)),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return _FavoriteCard(
                              item: item,
                              typeLabel: _typeLabel(item.targetType),
                              onTap: () => _openItem(item),
                              onRemove: () => _remove(item),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.item,
    required this.typeLabel,
    required this.onTap,
    required this.onRemove,
  });

  final FavoriteItem item;
  final String typeLabel;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEDF0F6)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFFFEFBC),
                child: Text(
                  item.title.isNotEmpty ? item.title.substring(0, 1) : '?',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF2E0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(typeLabel, style: const TextStyle(fontSize: 11, color: Color(0xFFD86A00))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (item.score != null) '评分 ${item.score}',
                        if (item.duration != null) item.duration,
                        if (item.category != null) item.category,
                        if (item.subtitle != null && item.subtitle!.isNotEmpty) item.subtitle,
                      ].join(' · '),
                      style: const TextStyle(color: Color(0xFF737C8B), fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.favorite, color: Color(0xFFFF7A22)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
