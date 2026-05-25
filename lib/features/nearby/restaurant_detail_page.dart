import 'package:flutter/material.dart';
import 'package:soulfood_front/features/favorite/favorite_repository.dart';
import 'package:soulfood_front/features/nearby/nearby_repository.dart';

class RestaurantDetailPage extends StatefulWidget {
  const RestaurantDetailPage({super.key, required this.restaurantId});

  final int restaurantId;

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  final _repo = NearbyRepository();
  final _favRepo = FavoriteRepository();
  RestaurantItem? _item;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final item = await _repo.getById(widget.restaurantId);
      if (mounted) setState(() => _item = item);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _want() async {
    final item = _item;
    if (item == null || _busy || item.wanted) return;
    setState(() => _busy = true);
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
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleFavorite() async {
    final item = _item;
    if (item == null || _busy) return;
    setState(() => _busy = true);
    try {
      if (item.favorited) {
        await _favRepo.removeRestaurant(item.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已取消收藏')));
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已收藏')));
        }
      }
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('餐厅详情')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final item = _item;
    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('餐厅详情')),
        body: const Center(child: Text('餐厅不存在')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEDF0F6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.category, style: const TextStyle(color: Color(0xFFD86A00), fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('评分 ${item.rating ?? '-'} · 距离 ${item.distanceKm ?? '-'} km'),
                  if (item.wanted)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('已标记想去', style: TextStyle(color: Color(0xFFD86A00), fontSize: 13)),
                    ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy || item.wanted ? null : _want,
                    icon: const Icon(Icons.flag_outlined),
                    label: Text(item.wanted ? '已想去' : '标记想去'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _toggleFavorite,
                    icon: Icon(item.favorited ? Icons.favorite : Icons.favorite_border),
                    label: Text(item.favorited ? '已收藏' : '收藏店铺'),
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF8A43)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
