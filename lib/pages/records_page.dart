import 'package:flutter/material.dart';

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  late final Future<RecordsData> _recordsFuture = _loadRecords();

  Future<RecordsData> _loadRecords() async {
    // TODO: 在这里接入后端接口并返回真实记录数据。
    return const RecordsData.empty();
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
              return const Center(
                child: Text(
                  '记录加载失败，请稍后重试',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF646871),
                  ),
                ),
              );
            }

            final RecordsData data = snapshot.data ?? const RecordsData.empty();
            return Column(
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
                const SizedBox(height: 16),
                Expanded(
                  child: data.records.isEmpty
                      ? const _EmptyRecords()
                      : ListView.separated(
                          itemCount: data.records.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (BuildContext context, int index) {
                            return _RecordItem(record: data.records[index]);
                          },
                        ),
                ),
              ],
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
                    stat.count != null ? '${stat.count}次' : '--',
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
        '暂无记录',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8D919A),
        ),
      ),
    );
  }
}

class _RecordItem extends StatelessWidget {
  const _RecordItem({required this.record});

  final RecordItem record;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
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
              child: const Icon(
                Icons.restaurant_rounded,
                color: Color(0xFFB3B8C2),
                size: 30,
              ),
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
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1F23),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${record.detail} · ${record.dateText}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8D919A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFC0C4CC),
            size: 28,
          ),
        ],
      ),
    );
  }
}

class RecordsData {
  const RecordsData({required this.stats, required this.records});

  const RecordsData.empty()
    : stats = const <RecordStat>[
        RecordStat(
          title: '观众悦度',
          backgroundColor: Color(0xFFFFD6D7),
          titleColor: Color(0xFFF05F65),
        ),
        RecordStat(
          title: '和朋友',
          backgroundColor: Color(0xFFFFEFBC),
          titleColor: Color(0xFFE0AF28),
        ),
        RecordStat(
          title: '健康',
          backgroundColor: Color(0xFFDDF6DF),
          titleColor: Color(0xFF48B86B),
        ),
        RecordStat(
          title: '收藏',
          backgroundColor: Color(0xFFE0E6FF),
          titleColor: Color(0xFF7E8BDF),
        ),
      ],
      records = const <RecordItem>[];

  final List<RecordStat> stats;
  final List<RecordItem> records;
}

class RecordStat {
  const RecordStat({
    required this.title,
    required this.backgroundColor,
    required this.titleColor,
    this.count,
  });

  final String title;
  final int? count;
  final Color backgroundColor;
  final Color titleColor;
}

class RecordItem {
  const RecordItem({
    required this.title,
    required this.detail,
    required this.dateText,
  });

  final String title;
  final String detail;
  final String dateText;
}
