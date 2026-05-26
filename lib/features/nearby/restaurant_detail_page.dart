import 'package:flutter/material.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/core/theme/theme_widgets.dart';
import 'package:soulfood_front/features/favorite/favorite_repository.dart';
import 'package:soulfood_front/features/nearby/nearby_repository.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _launch(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('无法打开链接')));
      }
    }
  }

  Future<void> _call(String phone) async {
    final normalized = phone.split(';').first.trim();
    await _launch(Uri(scheme: 'tel', path: normalized));
  }

  Future<void> _navigate(RestaurantItem item) async {
    if (item.lat != null && item.lng != null) {
      final uri = Uri.parse(
        'https://uri.amap.com/marker?position=${item.lng},${item.lat}&name=${Uri.encodeComponent(item.name)}',
      );
      await _launch(uri);
      return;
    }
    if (item.address != null && item.address!.isNotEmpty) {
      final uri = Uri.parse(
        'https://uri.amap.com/search?query=${Uri.encodeComponent(item.address!)}',
      );
      await _launch(uri);
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

    final phone = item.phone?.split(';').first.trim();
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (item.photoUrl != null && item.photoUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        item.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _PhotoPlaceholder(name: item.name),
                      ),
                    ),
                  )
                else
                  _PhotoPlaceholder(name: item.name),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: appCardDecoration(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.category,
                        style: TextStyle(color: colors.chipSelectedText, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text('评分 ${item.rating ?? '-'} · 距离 ${item.distanceKm ?? '-'} km'),
                      if (item.address != null && item.address!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.place_outlined, size: 16, color: colors.textSecondary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.address!,
                                style: TextStyle(color: colors.textSecondary, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (phone != null && phone.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined, size: 16, color: colors.textSecondary),
                            const SizedBox(width: 6),
                            Text(phone, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
                          ],
                        ),
                      ],
                      if (item.wanted)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '已标记想去',
                            style: TextStyle(color: colors.chipSelectedText, fontSize: 13),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (phone != null && phone.isNotEmpty)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _busy ? null : () => _call(phone),
                          icon: const Icon(Icons.phone_outlined),
                          label: const Text('拨打电话'),
                        ),
                      ),
                    if (phone != null && phone.isNotEmpty) const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _busy ? null : () => _navigate(item),
                        icon: const Icon(Icons.navigation_outlined),
                        label: const Text('导航'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [colors.bannerBackground, colors.chipSelectedBackground],
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.restaurant, size: 40, color: colors.accent),
          const SizedBox(height: 8),
          Text(name, style: TextStyle(fontWeight: FontWeight.w700, color: colors.chipSelectedText)),
        ],
      ),
    );
  }
}
