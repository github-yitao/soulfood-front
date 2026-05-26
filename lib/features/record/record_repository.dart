import 'package:soulfood_front/core/api/api_client.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';
import 'package:soulfood_front/features/record/record_models.dart';

class RecordRepository {
  RecordRepository() : _api = AppServices.I.api;

  final ApiClient _api;

  Future<RecordsData> loadOverview() async {
    final data = await _api.getData<Map<String, dynamic>>(
      '/api/v1/records/overview',
      parser: (json) => json as Map<String, dynamic>,
    );

    final statsJson = data['stats'] as List<dynamic>? ?? [];
    final recentJson = data['recent'] as List<dynamic>? ?? [];

    final stats = statsJson.map((raw) {
      final item = raw as Map<String, dynamic>;
      return RecordStat(
        key: item['key'] as String? ?? '',
        title: item['title'] as String? ?? '',
        count: (item['count'] as num?)?.toInt(),
      );
    }).toList();

    final records = recentJson
        .map((raw) => RecordItem.fromJson(raw as Map<String, dynamic>))
        .toList();

    return RecordsData(stats: stats, records: records);
  }
}
