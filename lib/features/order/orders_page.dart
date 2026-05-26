import 'package:flutter/material.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/core/theme/theme_widgets.dart';
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

  Future<void> _addManualOrder() async {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final summaryCtrl = TextEditingController();
    var category = 'food';

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('记一笔消费'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: '餐厅/店铺名称'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: '金额（元）'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: '分类'),
                  items: const [
                    DropdownMenuItem(value: 'food', child: Text('餐厅')),
                    DropdownMenuItem(value: 'drink', child: Text('饮品')),
                    DropdownMenuItem(value: 'fast', child: Text('快餐')),
                  ],
                  onChanged: (v) => setDialogState(() => category = v ?? 'food'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: summaryCtrl,
                  decoration: const InputDecoration(labelText: '备注（可选）', hintText: '2人 · 堂食'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );

    if (saved != true) {
      nameCtrl.dispose();
      amountCtrl.dispose();
      summaryCtrl.dispose();
      return;
    }

    final name = nameCtrl.text.trim();
    final amount = double.tryParse(amountCtrl.text.trim());
    final summary = summaryCtrl.text.trim();
    nameCtrl.dispose();
    amountCtrl.dispose();
    summaryCtrl.dispose();

    if (name.isEmpty || amount == null || amount <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请填写有效的店铺名称和金额')));
      }
      return;
    }

    try {
      await _repo.createManual(
        restaurantName: name,
        amount: amount,
        category: category,
        itemSummary: summary.isEmpty ? null : summary,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已记录')));
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final overview = _overview;
    final filteredDays = overview == null ? <OrderDayGroup>[] : _filteredDays(overview);
    final stats = _monthStats(filteredDays);
    final hasDemo = overview?.hasDemoOrders ?? false;

    final colors = context.appColors;

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addManualOrder,
        backgroundColor: colors.accent,
        icon: const Icon(Icons.add),
        label: const Text('记一笔'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                children: [
                  if (hasDemo)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: appStatusDecoration(colors, AppStatusKind.warning),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, size: 18, color: colors.warningText),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '列表中含示例订单（仅供体验），可通过「记一笔」添加真实消费记录。',
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.warningText,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  _OverviewCard(
                    month: _selectedMonth.month,
                    orderCount: stats.count,
                    totalAmount: stats.total,
                    topCategory: stats.topCategory,
                    hasDemo: hasDemo,
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
                        return AppFilterChip(
                          label: f.$2,
                          selected: active,
                          showCheckmark: false,
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
                      decoration: appMutedSurfaceDecoration(context, radius: 16),
                      child: Center(
                        child: Text(
                          '当前筛选下暂无订单，换个分类或月份看看。',
                          style: TextStyle(color: colors.textSecondary, fontSize: 13),
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
    this.hasDemo = false,
  });

  final int month;
  final int orderCount;
  final double totalAmount;
  final String topCategory;
  final bool hasDemo;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.heroGradientStart, colors.heroGradientEnd, colors.accent],
          stops: const [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$month 月消费概览${hasDemo ? '（含示例）' : ''}',
                style: TextStyle(color: colors.heroText, fontWeight: FontWeight.w800, fontSize: 16),
              ),
              Text(
                '近 30 天',
                style: TextStyle(color: colors.heroText.withValues(alpha: 0.8), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _metric(context, '订单数', '$orderCount'),
              _metric(context, '总消费', '¥${totalAmount.toStringAsFixed(0)}'),
              _metric(context, '常点品类', topCategory),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(BuildContext context, String label, String value) {
    final colors = context.appColors;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: colors.heroText.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.heroText.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: colors.heroText.withValues(alpha: 0.82), fontSize: 11),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.heroText, fontWeight: FontWeight.w800, fontSize: 18),
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
    final colors = context.appColors;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 5,
          top: 8,
          bottom: 8,
          child: Container(
            width: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colors.accentSecondary, colors.chipSelectedBackground],
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
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colors.accent,
                shape: BoxShape.circle,
                border: Border.all(color: colors.chipSelectedBackground, width: 3),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                day.dateLabel,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: colors.textSecondary),
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
    final colors = context.appColors;
    final pending = item.statusText == '待开发票';
    final metaParts = _metaParts(item);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: appCardDecoration(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.restaurantName,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: colors.textPrimary),
                ),
                if (item.isDemo) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: appStatusDecoration(colors, AppStatusKind.warning),
                    child: Text(
                      '示例',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: colors.warningText),
                    ),
                  ),
                ],
                if (metaParts.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: metaParts
                        .map(
                          (part) => Text(
                            part,
                            style: TextStyle(color: colors.textSecondary, fontSize: 12),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (item.statusText != null) ...[
                  const SizedBox(height: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: appStatusDecoration(
                      colors,
                      pending ? AppStatusKind.warning : AppStatusKind.info,
                    ),
                    child: Text(
                      item.statusText!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: appStatusTextColor(
                          colors,
                          pending ? AppStatusKind.warning : AppStatusKind.info,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '¥${item.amount.toStringAsFixed(0)}',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: colors.textPrimary),
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
