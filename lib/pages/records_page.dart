import 'package:flutter/material.dart';
import 'package:soulfood_front/features/record/record_detail_page.dart';
import 'package:soulfood_front/features/record/record_models.dart';
import 'package:soulfood_front/features/record/record_repository.dart';

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  final _repo = RecordRepository();
  late Future<RecordsData> _recordsFuture = _loadRecords();

  Future<RecordsData> _loadRecords() {
    return _repo.loadOverview();
  }

  Future<void> _refresh() async {
    setState(() {
      _recordsFuture = _loadRecords();
    });
    await _recordsFuture;
  }

  void _openDetail(RecordItem record) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => RecordDetailPage(record: record)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
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
                    const Text(
                      '记录加载失败，请确认后端已启动',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF646871),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '我的记录',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E1F23),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _StatsGrid(stats: data.stats),
                  const SizedBox(height: 34),
                  const Text(
                    '最近记录',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E1F23),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '点击查看详情',
                    style: TextStyle(fontSize: 13, color: Color(0xFF8D919A)),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: data.records.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 120, child: _EmptyRecords()),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: data.records.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 14),
                            itemBuilder: (BuildContext context, int index) {
                              return _RecordItem(
                                record: data.records[index],
                                onTap: () => _openDetail(data.records[index]),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final List<RecordStat> stats;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: stats
          .map(
            (RecordStat stat) => Container(
              width: 112,
              height: 100,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              decoration: BoxDecoration(
                color: stat.backgroundColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: stat.titleColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${stat.count ?? 0}次',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E1F23),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _EmptyRecords extends StatelessWidget {
  const _EmptyRecords();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '暂无记录，去投票或标记「想去」后会出现在这里',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8D919A),
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 70,
                  height: 70,
                  color: const Color(0xFFF1F3F6),
                  alignment: Alignment.center,
                  child: Icon(record.typeIcon, color: const Color(0xFFB3B8C2), size: 30),
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
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E1F23),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${record.detail} · ${record.dateText}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8D919A),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFB3B8C2)),
            ],
          ),
        ),
      ),
    );
  }
}
