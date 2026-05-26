import 'package:flutter/material.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/features/nearby/nearby_repository.dart';
import 'package:soulfood_front/features/nearby/restaurant_detail_page.dart';
import 'package:soulfood_front/routing/app_routes.dart';

class WantedRestaurantsPage extends StatefulWidget {
  const WantedRestaurantsPage({super.key});

  @override
  State<WantedRestaurantsPage> createState() => _WantedRestaurantsPageState();
}

class _WantedRestaurantsPageState extends State<WantedRestaurantsPage> {
  final _repo = NearbyRepository();
  List<RestaurantItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await _repo.listWanted();
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _remove(RestaurantItem item) async {
    try {
      await _repo.removeWant(item.id);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('已取消想去：${item.name}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
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

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      appBar: AppBar(title: const Text('想去清单')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _items.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        Center(
                          child: Text(
                            '还没有标记「想去」的餐厅',
                            style: TextStyle(color: colors.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 36),
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                Navigator.pushNamed(context, AppRoutes.nearby),
                            icon: const Icon(Icons.explore_outlined),
                            label: const Text('去附近吃什么标记想去'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            '在店铺卡片右侧点击「想去」即可加入清单',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: colors.cardBorder),
                          ),
                          tileColor: colors.cardBackground,
                          title: Text(
                            item.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            [
                              item.category,
                              if (item.distanceKm != null)
                                '${item.distanceKm!.toStringAsFixed(1)}km',
                              if (item.rating != null) '${item.rating}分',
                            ].where((e) => e.isNotEmpty).join(' · '),
                            style: TextStyle(color: colors.textSecondary),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.bookmark_remove_outlined,
                              color: colors.textSecondary,
                            ),
                            onPressed: () => _remove(item),
                          ),
                          onTap: () => _openDetail(item),
                        );
                      },
                    ),
            ),
    );
  }
}
