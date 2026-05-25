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
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
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

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(now.year - 2, 1),
      lastDate: now,
      helpText: '选择月份',
    );
    if (picked != null && mounted) {
      setState(() => _selectedMonth = DateTime(picked.year, picked.month));
    }
  }

  List<OrderDayGroup> _filteredDays(OrderOverview overview) {
    return overview.days.where((day) {
      final match = RegExp(r'(\d{4})-(\d{2})').firstMatch(day.dateLabel);
      if (match == null) return true;
      final year = int.tryParse(match.group(1)!);
      final month = int.tryParse(match.group(2)!);
      if (year == null || month == null) return true;
      return year == _selectedMonth.year && month == _selectedMonth.month;
    }).toList();
  }

  ({int count, double total, String topCategory}) _monthStats(List<OrderDayGroup> days) {
    var count = 0;
    var total = 0.0;
    final categoryCount = <String, int>{};
    for (final day in days) {
      for (final item in day.items) {
        count++;
        total += item.amount;
        final cat = item.category ?? day.category ?? '其他';
        categoryCount[cat] = (categoryCount[cat] ?? 0) + 1;
      }
    }
    final topCategory = categoryCount.entries.isEmpty
        ? '—'
        : categoryCount.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    return (count: count, total: total, topCategory: _categoryLabel(topCategory));
  }

  String _categoryLabel(String raw) => switch (raw) {
        'food' => '餐厅',
        'drink' => '饮品',
        'fast' => '快餐',
        _ => raw,
      };

  @override
  Widget build(BuildContext context) {
    final overview = _overview;
    final filteredDays = overview == null ? <OrderDayGroup>[] : _filteredDays(overview);
    final stats = _monthStats(filteredDays);

    return Scaffold(
      appBar: AppBar(
        title: const Text('历史订单'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: '筛选月份',
            onPressed: _pickMonth,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  _OverviewCard(
                    month: _selectedMonth.month,
                    orderCount: stats.count,
                    totalAmount: stats.total,
                    topCategory: stats.topCategory,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final f = _filters[index];
                        final active = _filter == f.$1;
                        return FilterChip(
                          label: Text(f.$2),
                          selected: active,
                          showCheckmark: false,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: active ? const Color(0xFFD86A00) : const Color(0xFF5F697A),
                          ),
                          backgroundColor: const Color(0xFFF7F9FC),
                          selectedColor: const Color(0xFFFFF2E0),
                          side: BorderSide(
                            color: active ? const Color(0xFFFFD79F) : const Color(0xFFE8EDF4),
                          ),
                          onSelected: (_) {
                            setState(() => _filter = f.$1);
                            _load();
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (filteredDays.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBFCFF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE3E8F0), style: BorderStyle.solid),
                      ),
                      child: const Center(
                        child: Text(
                          '当前筛选下暂无订单，换个分类或月份看看。',
                          style: TextStyle(color: Color(0xFF7C8594), fontSize: 13),
                        ),
                      ),
                    )
                  else
                    _OrderTimeline(days: filteredDays),
                ],
              ),
            ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.month,
    required this.orderCount,
    required this.totalAmount,
    required this.topCategory,
  });

  final int month;
  final int orderCount;
  final double totalAmount;
  final String topCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F2E45), Color(0xFF2F4569)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x38142138), blurRadius: 24, offset: Offset(0, 12)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$month 月消费概览',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const Text('近 30 天', style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _metric('订单数', '$orderCount'),
              _metric('总消费', '¥${totalAmount.toStringAsFixed(0)}'),
              _metric('常点品类', topCategory),
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Color(0xD1FFFFFF), fontSize: 11)),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  const _OrderTimeline({required this.days});

  final List<OrderDayGroup> days;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 5,
          top: 8,
          bottom: 8,
          child: Container(
            width: 2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFD9AD), Color(0xFFFFEEDE)],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 18),
          child: Column(
            children: [
              for (final day in days) ...[
                _DayBlock(day: day),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DayBlock extends StatelessWidget {
  const _DayBlock({required this.day});

  final OrderDayGroup day;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFFF9A4D),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFF1E3), width: 3),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                day.dateLabel,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF687184)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final item in day.items) ...[
          _OrderCard(item: item),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final pending = item.statusText == '待开发票';
    final metaParts = _metaParts(item);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDF1F6)),
        boxShadow: const [
          BoxShadow(color: Color(0x141E2941), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.restaurantName,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1F2633)),
                ),
                if (metaParts.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: metaParts
                        .map(
                          (part) => Text(
                            part,
                            style: const TextStyle(color: Color(0xFF6F7889), fontSize: 12),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (item.statusText != null) ...[
                  const SizedBox(height: 7),
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
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF222A39)),
          ),
        ],
      ),
    );
  }

  List<String> _metaParts(OrderItem item) {
    if (item.itemSummary != null && item.itemSummary!.contains('·')) {
      return item.itemSummary!.split('·').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }
    final parts = <String>[];
    if (item.timeText != null && item.timeText!.isNotEmpty) parts.add(item.timeText!);
    if (item.itemSummary != null && item.itemSummary!.isNotEmpty) parts.add(item.itemSummary!);
    return parts;
  }
}
