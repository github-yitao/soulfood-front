import 'package:flutter/material.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';
import 'package:soulfood_front/pages/records_page.dart';

class RecordRepository {
  RecordRepository() : _api = AppServices.I.api;

  final dynamic _api;

  Future<RecordsData> loadOverview() async {
    final data = await _api.getData<Map<String, dynamic>>(
      '/api/v1/records/overview',
      parser: (json) => json as Map<String, dynamic>,
    );

    final statsJson = data['stats'] as List<dynamic>? ?? [];
    final recentJson = data['recent'] as List<dynamic>? ?? [];

    final stats = statsJson.map((raw) {
      final item = raw as Map<String, dynamic>;
      final key = item['key'] as String? ?? '';
      return RecordStat(
        title: item['title'] as String? ?? '',
        count: (item['count'] as num?)?.toInt(),
        backgroundColor: _statColor(key),
        titleColor: _statTitleColor(key),
      );
    }).toList();

    final records = recentJson.map((raw) {
      final item = raw as Map<String, dynamic>;
      return RecordItem(
        title: item['title'] as String? ?? '',
        detail: item['summary'] as String? ?? '',
        dateText: item['occurredAt'] as String? ?? '',
      );
    }).toList();

    return RecordsData(stats: stats, records: records);
  }

  Color _statColor(String key) {
    switch (key) {
      case 'vote':
        return const Color(0xFFFFD6D7);
      case 'friends':
        return const Color(0xFFFFEFBC);
      case 'eat':
        return const Color(0xFFDDF6DF);
      case 'favorite':
        return const Color(0xFFE0E6FF);
      default:
        return const Color(0xFFF1F3F6);
    }
  }

  Color _statTitleColor(String key) {
    switch (key) {
      case 'vote':
        return const Color(0xFFF05F65);
      case 'friends':
        return const Color(0xFFE0AF28);
      case 'eat':
        return const Color(0xFF48B86B);
      case 'favorite':
        return const Color(0xFF7E8BDF);
      default:
        return const Color(0xFF646871);
    }
  }
}
