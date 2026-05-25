import 'package:flutter/material.dart';
import 'package:soulfood_front/features/order/order_repository.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _repo = OrderRepository();
  static const _filters = [
    ('all', '全部'),
    ('food', '餐厅'),
    ('drink', '饮品'),
    ('fast', '快餐'),
  ];

  String _filter = 'all';
  OrderOverview? _overview;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final category = _filter == 'all' ? null : _filter;
      final overview = await _repo.loadOverview(category: category);
      if (mounted) setState(() => _overview = overview);
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
    final overview = _overview;
    return Scaffold(
      appBar: AppBar(title: const Text('历史订单')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (overview != null) _OverviewCard(overview: overview),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
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
                  const SizedBox(height: 16),
                  if (overview == null || overview.days.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text('暂无订单', style: TextStyle(color: Color(0xFF8D919A))),
                      ),
                    )
                  else
                    ...overview.days.expand((day) sync* {
                      yield Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 4),
                        child: Text(
                          day.dateLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF687184),
                          ),
                        ),
                      );
                      for (final item in day.items) {
                        yield Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _OrderCard(item: item),
                        );
                      }
                    }),
                ],
              ),
            ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.overview});

  final OrderOverview overview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F2E45), Color(0xFF2F4569)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('消费概览', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              Text('近 30 天', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _metric('订单数', '${overview.orderCount}'),
              _metric('总消费', '¥${overview.totalAmount.toStringAsFixed(0)}'),
              _metric('常点品类', overview.topCategory),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final pending = item.statusText == '待开发票';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDF1F6)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.restaurantName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  item.itemSummary ?? '',
                  style: const TextStyle(color: Color(0xFF6F7889), fontSize: 12),
                ),
                if (item.statusText != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: pending ? const Color(0xFFFFF2E3) : const Color(0xFFEEF7FF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item.statusText!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: pending ? const Color(0xFFDE7312) : const Color(0xFF3171CB),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '¥${item.amount.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
