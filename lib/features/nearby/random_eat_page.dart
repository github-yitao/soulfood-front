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

  @override
  void initState() {
    super.initState();
    _load();
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
      final items = await _repo.list(lat: location?.lat, lng: location?.lng);
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _picking = false);
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: appStatusDecoration(colors, AppStatusKind.info),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, size: 14, color: colors.infoText),
                      const SizedBox(width: 4),
                      Text(
                        'AI 决策',
                        style: TextStyle(fontSize: 12, color: colors.infoText, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '附近吃什么',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.15),
                ),
                const SizedBox(height: 6),
                Text(
                  '发现附近美食，或由 AI 帮你拍板',
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
                        SizedBox(height: 160, child: Center(child: CircularProgressIndicator())),
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
                                  item.name.isNotEmpty ? item.name.substring(0, 1) : '?',
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ),
                              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Text('${item.category} · ${item.distanceKm ?? '-'} km'),
                              trailing: Text('${item.rating ?? '-'}'),
                            ),
                          ),
                        ),
                        if (_pickName != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: appStatusDecoration(colors, AppStatusKind.info),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('今天就吃', style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                                const SizedBox(height: 4),
                                Text(
                                  _pickName!,
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                                ),
                                if (_pickReason != null && _pickReason!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    _pickReason!,
                                    style: TextStyle(color: colors.textSecondary, fontSize: 13),
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
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
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
