import 'package:flutter/material.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/core/theme/theme_widgets.dart';
import 'package:soulfood_front/features/favorite/favorites_page.dart';
import 'package:soulfood_front/features/notification/notification_repository.dart';
import 'package:soulfood_front/features/order/orders_page.dart';
import 'package:soulfood_front/features/record/record_detail_page.dart';
import 'package:soulfood_front/features/record/record_stat_style.dart';
import 'package:soulfood_front/features/record/record_models.dart';
import 'package:soulfood_front/features/record/record_repository.dart';
import 'package:soulfood_front/routing/app_routes.dart';
import 'package:soulfood_front/widgets/quick_action_grid.dart';

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  final _repo = RecordRepository();
  final _notificationRepo = NotificationRepository(AppServices.I.api);
  late Future<RecordsData> _recordsFuture = _loadRecords();
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<RecordsData> _loadRecords() {
    return _repo.loadOverview();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final overview = await _notificationRepo.load();
      if (mounted) setState(() => _unreadNotifications = overview.unreadCount);
    } catch (_) {}
  }

  Future<void> _refresh() async {
    setState(() {
      _recordsFuture = _loadRecords();
    });
    await _recordsFuture;
    await _loadUnreadCount();
  }

  void _openDetail(RecordItem record) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => RecordDetailPage(record: record)),
    );
  }

  void _open(Widget page) {
    Navigator.push<void>(context, MaterialPageRoute<void>(builder: (_) => page));
  }

  Future<void> _openNotifications() async {
    await Navigator.pushNamed(context, AppRoutes.notifications);
    _loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SafeArea(
      child: FutureBuilder<RecordsData>(
        future: _recordsFuture,
        builder: (BuildContext context, AsyncSnapshot<RecordsData> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '记录加载失败，请确认后端已启动',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _refresh, child: const Text('重试')),
                ],
              ),
            );
          }

          final RecordsData data = snapshot.data ?? const RecordsData.empty();
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              children: [
                Text(
                  '我的记录',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                _StatsGrid(stats: data.stats),
                const SizedBox(height: 28),
                Text(
                  '我的足迹',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                QuickActionGrid(
                  actions: [
                    QuickAction(
                      icon: Icons.receipt_long_outlined,
                      label: '历史订单',
                      onTap: () => _open(const OrdersPage()),
                    ),
                    QuickAction(
                      icon: Icons.favorite_outline,
                      label: '我的收藏',
                      onTap: () => _open(const FavoritesPage()),
                    ),
                    QuickAction(
                      icon: Icons.bookmark_outline,
                      label: '想去清单',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.wantedRestaurants),
                    ),
                    QuickAction(
                      icon: Icons.notifications_outlined,
                      label: '消息通知',
                      badge: _unreadNotifications > 0 ? '$_unreadNotifications' : null,
                      onTap: _openNotifications,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  '最近记录',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '点击查看详情',
                  style: TextStyle(fontSize: 13, color: colors.textSecondary),
                ),
                const SizedBox(height: 12),
                if (data.records.isEmpty)
                  const SizedBox(height: 120, child: _EmptyRecords())
                else
                  ...data.records.map(
                    (record) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _RecordItem(
                        record: record,
                        onTap: () => _openDetail(record),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final List<RecordStat> stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: stats
          .map(
            (RecordStat stat) {
              final style = recordStatStyle(context, stat.key);
              return Container(
                width: 112,
                height: 100,
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                decoration: BoxDecoration(
                  color: style.background,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: colors.cardBorder.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.6 : 0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: style.titleColor,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${stat.count ?? 0}次',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            },
          )
          .toList(),
    );
  }
}

class _EmptyRecords extends StatelessWidget {
  const _EmptyRecords();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Text(
        '暂无记录，去投票或标记「想去」后会出现在这里',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colors.textSecondary,
        ),
      ),
    );
  }
}

class _RecordItem extends StatelessWidget {
  const _RecordItem({required this.record, required this.onTap});

  final RecordItem record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.cardBackground,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: appCardDecoration(context, radius: 18),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 70,
                  height: 70,
                  color: colors.chipBackground,
                  alignment: Alignment.center,
                  child: Icon(record.typeIcon, color: colors.offline, size: 30),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${record.detail} · ${record.dateText}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.offline),
            ],
          ),
        ),
      ),
    );
  }
}
