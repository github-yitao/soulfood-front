import 'dart:async';

import 'package:flutter/material.dart';
import 'package:soulfood_front/core/location/location_service.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/core/theme/theme_widgets.dart';
import 'package:soulfood_front/features/agent/agent_repository.dart';
import 'package:soulfood_front/features/nearby/nearby_repository.dart';
import 'package:soulfood_front/features/room/room_repository.dart';
import 'package:soulfood_front/routing/app_routes.dart';

/// 随机吃什么 — 对齐原型 07-nearby：附近店列表 + AI 随机拍板
class RandomEatPage extends StatefulWidget {
  const RandomEatPage({super.key});

  @override
  State<RandomEatPage> createState() => _RandomEatPageState();
}

class _RandomEatPageState extends State<RandomEatPage> {
  final _repo = NearbyRepository();
  final _agent = AgentRepository();
  final _roomRepo = RoomRepository();

  List<RestaurantItem> _items = [];
  bool _loading = true;
  bool _picking = false;
  String? _pickName;
  String? _pickReason;
  bool _usingFallback = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      if (_items.isEmpty) {
        _items = _fallbackRestaurants();
        _usingFallback = true;
      }
    });
    try {
      final items = await _repo.list().timeout(const Duration(seconds: 4));
      if (mounted) {
        setState(() {
          _items = items;
          _usingFallback = false;
        });
      }
      unawaited(_refreshWithLocation());
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _items = _fallbackRestaurants();
          _usingFallback = true;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('附近数据加载超时，先用常见候选帮你随机')));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _items = _fallbackRestaurants();
          _usingFallback = true;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refreshWithLocation() async {
    try {
      final location = await LocationService.current().timeout(
        const Duration(seconds: 2),
      );
      if (location == null) return;
      final items = await _repo
          .list(lat: location.lat, lng: location.lng)
          .timeout(const Duration(seconds: 4));
      if (!mounted || items.isEmpty) return;
      setState(() {
        _items = items;
        _usingFallback = false;
      });
    } catch (_) {
      // 静默失败，保持当前列表即可。
    }
  }

  List<RestaurantItem> _fallbackRestaurants() {
    return [
      RestaurantItem(
        id: -1,
        name: '火锅',
        category: '热门',
        rating: 4.8,
        distanceKm: null,
        wanted: false,
        favorited: false,
      ),
      RestaurantItem(
        id: -2,
        name: '烤肉',
        category: '热门',
        rating: 4.7,
        distanceKm: null,
        wanted: false,
        favorited: false,
      ),
      RestaurantItem(
        id: -3,
        name: '面馆',
        category: '快选',
        rating: 4.6,
        distanceKm: null,
        wanted: false,
        favorited: false,
      ),
      RestaurantItem(
        id: -4,
        name: '麻辣烫',
        category: '快选',
        rating: 4.5,
        distanceKm: null,
        wanted: false,
        favorited: false,
      ),
      RestaurantItem(
        id: -5,
        name: '轻食沙拉',
        category: '清淡',
        rating: 4.4,
        distanceKm: null,
        wanted: false,
        favorited: false,
      ),
    ];
  }

  Future<void> _aiRandomPick() async {
    if (_items.isEmpty) return;
    setState(() => _picking = true);
    try {
      final pick = await _agent.randomPick(
        candidates: _items.map((e) => e.name).toList(),
      );
      if (mounted) {
        setState(() {
          _pickName = pick.name;
          _pickReason = pick.reason;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _startVote() async {
    if (_items.isEmpty) return;
    setState(() => _picking = true);
    try {
      final names = _items.take(5).map((e) => e.name).toList();
      final room = await _roomRepo.createRoom(
        topic: '随机吃什么投票',
        initialOptions: names,
      );
      if (!mounted) return;
      Navigator.pushNamed(context, AppRoutes.vote, arguments: room.code);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _want(RestaurantItem item) async {
    if (item.id <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('当前是离线候选，无法加入想去清单')));
      }
      return;
    }
    try {
      await _repo.markWant(item.id);
      if (!mounted) return;
      setState(() {
        _items = _items
            .map(
              (e) => e.id == item.id
                  ? RestaurantItem(
                      id: e.id,
                      name: e.name,
                      category: e.category,
                      rating: e.rating,
                      distanceKm: e.distanceKm,
                      wanted: true,
                      favorited: e.favorited,
                      address: e.address,
                      lat: e.lat,
                      lng: e.lng,
                      phone: e.phone,
                      photoUrl: e.photoUrl,
                    )
                  : e,
            )
            .toList();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('已标记想去：${item.name}')));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      appBar: AppBar(title: const Text('随机吃什么')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: appStatusDecoration(colors, AppStatusKind.info),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: colors.infoText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'AI 决策',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.infoText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '随机吃什么',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _usingFallback ? '网络较慢，先从常见候选里随机' : '发现附近美食，或由 AI 帮你拍板',
                  style: TextStyle(color: colors.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: _loading && _items.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(
                          height: 160,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                      children: [
                        ..._items.map(
                          (item) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: colors.chipSelectedBackground,
                                child: Text(
                                  item.name.isNotEmpty
                                      ? item.name.substring(0, 1)
                                      : '?',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              title: Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                '${item.category} · ${item.distanceKm ?? '-'} km',
                              ),
                              trailing: FilledButton.tonal(
                                onPressed: () => _want(item),
                                child: Text(item.wanted ? '已想去' : '想去'),
                              ),
                            ),
                          ),
                        ),
                        if (_pickName != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: appStatusDecoration(
                              colors,
                              AppStatusKind.info,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '今天就吃',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _pickName!,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (_pickReason != null &&
                                    _pickReason!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    _pickReason!,
                                    style: TextStyle(
                                      color: colors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 80),
                      ],
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: OutlinedButton.icon(
              onPressed: _picking || _items.isEmpty ? null : _aiRandomPick,
              icon: _picking
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.casino),
              label: const Text('AI 随机帮我选'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: FilledButton(
              onPressed: _picking || _items.isEmpty ? null : _startVote,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('发起投票'),
            ),
          ),
        ],
      ),
    );
  }
}
