import 'package:flutter/material.dart';
import 'package:soulfood_front/core/location/location_service.dart';
import 'package:soulfood_front/features/agent/agent_repository.dart';
import 'package:soulfood_front/features/favorite/favorite_repository.dart';
import 'package:soulfood_front/features/nearby/nearby_repository.dart';
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
      appBar: AppBar(
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
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: '搜索餐厅或菜系',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                    _load();
                  },
                ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _load(),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: _chips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final chip = _chips[index];
                return ChoiceChip(
                  label: Text(chip['label']!),
                  selected: _category == chip['id'],
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
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Card(
                          child: ListTile(
                            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text('${item.category} · ${item.distanceKm ?? '-'} km'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${item.rating ?? '-'}'),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.wanted ? '已想去' : '',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFFD86A00)),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  tooltip: item.favorited ? '取消收藏' : '收藏店铺',
                                  icon: Icon(
                                    item.favorited ? Icons.favorite : Icons.favorite_border,
                                    color: item.favorited
                                        ? const Color(0xFFFF7A22)
                                        : const Color(0xFF8D919A),
                                  ),
                                  onPressed: () => _toggleFavorite(item),
                                ),
                              ],
                            ),
                            onTap: () => _want(item),
                          ),
                        );
                      },
                    ),
            ),
          ),
          if (_aiPickName != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
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
                        Icon(Icons.casino, color: Color(0xFF2B5EA8), size: 18),
                        SizedBox(width: 6),
                        Text('AI 帮你选', style: TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _aiPickName!,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    if (_aiPickReason != null && _aiPickReason!.isNotEmpty)
                      Text(_aiPickReason!, style: const TextStyle(color: Color(0xFF5F6B7F), fontSize: 13)),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: OutlinedButton.icon(
              onPressed: _loading || _items.isEmpty ? null : _aiRandomPick,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('AI 随机帮我选'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                foregroundColor: const Color(0xFF2B5EA8),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: FilledButton(
              onPressed: _loading || _items.isEmpty ? null : _startVote,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: const Color(0xFFFF8A43),
              ),
              child: const Text('用这些店发起投票'),
            ),
          ),
        ],
      ),
    );
  }
}
