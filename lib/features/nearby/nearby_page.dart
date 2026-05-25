import 'package:flutter/material.dart';
import 'package:soulfood_front/core/location/location_service.dart';
import 'package:soulfood_front/features/agent/agent_repository.dart';
import 'package:soulfood_front/features/favorite/favorite_repository.dart';
import 'package:soulfood_front/features/nearby/nearby_repository.dart';
import 'package:soulfood_front/features/nearby/restaurant_detail_page.dart';
import 'package:soulfood_front/features/room/room_repository.dart';
import 'package:soulfood_front/routing/app_routes.dart';

class NearbyPage extends StatefulWidget {
  const NearbyPage({super.key});

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  final _repo = NearbyRepository();
  final _favRepo = FavoriteRepository();
  final _agent = AgentRepository();
  final _roomRepo = RoomRepository();
  String? _aiPickName;
  String? _aiPickReason;
  final _searchCtrl = TextEditingController();
  List<RestaurantItem> _items = [];
  String _category = 'all';
  bool _loading = true;

  static const _chips = <Map<String, String>>[
    {'id': 'all', 'label': '全部'},
    {'id': 'hotpot', 'label': '火锅'},
    {'id': 'drink', 'label': '饮品'},
    {'id': 'fast', 'label': '快餐'},
    {'id': 'bbq', 'label': '烤肉'},
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final location = await LocationService.current();
      if (mounted && location == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('未获取定位，将按默认区域搜索附近餐厅')),
        );
      }
      final items = await _repo.list(
        lat: location?.lat,
        lng: location?.lng,
        category: _category == 'all' ? null : _category,
        keyword: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
      );
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _want(RestaurantItem item) async {
    try {
      await _repo.markWant(item.id);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已标记想去：${item.name}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  void _openDetail(RestaurantItem item) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => RestaurantDetailPage(restaurantId: item.id),
      ),
    ).then((_) => _load());
  }

  Future<void> _toggleFavorite(RestaurantItem item) async {
    try {
      if (item.favorited) {
        await _favRepo.removeRestaurant(item.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已取消收藏：${item.name}')));
        }
      } else {
        await _favRepo.addRestaurant(
          restaurantId: item.id,
          title: item.name,
          subtitle: item.category,
          category: item.category,
          score: item.rating?.toString(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已收藏，可在「我的收藏」查看')),
          );
        }
      }
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _aiRandomPick() async {
    if (_items.isEmpty) return;
    setState(() => _loading = true);
    try {
      final pick = await _agent.randomPick(
        candidates: _items.map((e) => e.name).toList(),
      );
      if (mounted) {
        setState(() {
          _aiPickName = pick.name;
          _aiPickReason = pick.reason;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startVote() async {
    if (_items.isEmpty) return;
    setState(() => _loading = true);
    try {
      final names = _items.take(5).map((e) => e.name).toList();
      final room = await _roomRepo.createRoom(
        topic: '附近觅食投票',
        initialOptions: names,
      );
      if (!mounted) return;
      Navigator.pushNamed(context, AppRoutes.vote, arguments: room.code);
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('附近觅食'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.my_location_outlined),
            tooltip: '刷新定位',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              '探店用：看看你周边有什么好吃的',
              style: TextStyle(fontSize: 13, color: Color(0xFF6E7788), height: 1.35),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: '搜索商圈、餐厅或菜系',
                hintStyle: const TextStyle(color: Color(0xFF7C8596), fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF7C8596)),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchCtrl.clear();
                          _load();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF8FAFD),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE9EDF4)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE9EDF4)),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _load(),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              itemCount: _chips.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final chip = _chips[index];
                final selected = _category == chip['id'];
                return FilterChip(
                  label: Text(chip['label']!),
                  selected: selected,
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? const Color(0xFFD86A00) : const Color(0xFF5F697A),
                  ),
                  backgroundColor: const Color(0xFFF7F9FC),
                  selectedColor: const Color(0xFFFFF2E0),
                  side: BorderSide(
                    color: selected ? const Color(0xFFFFD79F) : const Color(0xFFE8EDF4),
                  ),
                  onSelected: (_) {
                    setState(() => _category = chip['id']!);
                    _load();
                  },
                );
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: _loading && _items.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                      itemCount: _items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return _ShopCard(
                          item: item,
                          onTap: () => _openDetail(item),
                          onWant: () => _want(item),
                          onFavorite: () => _toggleFavorite(item),
                        );
                      },
                    ),
            ),
          ),
          if (_aiPickName != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF4FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFB8D4F8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Color(0xFF2B5EA8), size: 18),
                        SizedBox(width: 6),
                        Text('AI 帮你挑', style: TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _aiPickName!,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    if (_aiPickReason != null && _aiPickReason!.isNotEmpty)
                      Text(
                        _aiPickReason!,
                        style: const TextStyle(color: Color(0xFF5F6B7F), fontSize: 13),
                      ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: OutlinedButton.icon(
              onPressed: _loading || _items.isEmpty ? null : _aiRandomPick,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('AI 帮我挑一家'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                foregroundColor: const Color(0xFF2B5EA8),
                side: const BorderSide(color: Color(0xFFB8D4F8)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: FilledButton(
              onPressed: _loading || _items.isEmpty ? null : _startVote,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                backgroundColor: const Color(0xFFFF8A43),
              ),
              child: const Text('用这些店发起投票', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({
    required this.item,
    required this.onTap,
    required this.onWant,
    required this.onFavorite,
  });

  final RestaurantItem item;
  final VoidCallback onTap;
  final VoidCallback onWant;
  final VoidCallback onFavorite;

  IconData _categoryIcon() {
    final cat = item.category.toLowerCase();
    if (cat.contains('火锅')) return Icons.local_fire_department_outlined;
    if (cat.contains('饮') || cat.contains('茶') || cat.contains('咖啡')) {
      return Icons.local_cafe_outlined;
    }
    if (cat.contains('快餐')) return Icons.fastfood_outlined;
    if (cat.contains('烤')) return Icons.outdoor_grill_outlined;
    return Icons.restaurant_outlined;
  }

  List<Color> _thumbGradient() {
    final cat = item.category.toLowerCase();
    if (cat.contains('饮') || cat.contains('茶')) {
      return const [Color(0xFF94E3CB), Color(0xFF39B59A)];
    }
    if (cat.contains('快餐')) {
      return const [Color(0xFFFFC8CA), Color(0xFFFF8F99)];
    }
    return const [Color(0xFFFFD58F), Color(0xFFFF9C6A)];
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEDF1F6)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x141E2941),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      Container(
                        width: 74,
                        height: 74,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _thumbGradient(),
                          ),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
                        ),
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.94),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(_categoryIcon(), size: 22, color: const Color(0xFF3A4252)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1F2633),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Text(
                                  item.category,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF707A8C)),
                                ),
                                Text(
                                  '${item.distanceKm ?? '-'} km',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF707A8C)),
                                ),
                                if (item.rating != null)
                                  Text(
                                    '★ ${item.rating}',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF707A8C)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: const Color(0xFFFFF1E3),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: onWant,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFD8B1)),
                        ),
                        child: Text(
                          item.wanted ? '已想去' : '想去',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: item.wanted ? const Color(0xFF8D919A) : const Color(0xFFFF7A22),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    tooltip: item.favorited ? '取消收藏' : '收藏',
                    icon: Icon(
                      item.favorited ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: item.favorited
                          ? const Color(0xFFFF7A22)
                          : const Color(0xFF8D919A),
                    ),
                    onPressed: onFavorite,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
