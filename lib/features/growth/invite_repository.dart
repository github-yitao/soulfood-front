import 'package:soulfood_front/core/api/api_client.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';

class InviteOverview {
  InviteOverview({
    required this.inviteCode,
    required this.completedCount,
    required this.targetCount,
    required this.records,
  });

  final String inviteCode;
  final int completedCount;
  final int targetCount;
  final List<InviteRecord> records;

  factory InviteOverview.fromJson(Map<String, dynamic> json) {
    final recordsJson = json['records'] as List<dynamic>? ?? [];
    return InviteOverview(
      inviteCode: json['inviteCode'] as String? ?? '',
      completedCount: (json['completedCount'] as num?)?.toInt() ?? 0,
      targetCount: (json['targetCount'] as num?)?.toInt() ?? 5,
      records: recordsJson
          .map((e) => InviteRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class InviteRecord {
  InviteRecord({
    required this.nickname,
    required this.registeredAt,
    required this.statusLabel,
  });

  final String nickname;
  final String registeredAt;
  final String statusLabel;

  factory InviteRecord.fromJson(Map<String, dynamic> json) {
    return InviteRecord(
      nickname: json['nickname'] as String? ?? '好友',
      registeredAt: json['registeredAt'] as String? ?? '',
      statusLabel: json['statusLabel'] as String? ?? '',
    );
  }
}

class InviteRepository {
  InviteRepository() : _api = AppServices.I.api;

  final ApiClient _api;

  Future<InviteOverview> loadOverview() async {
    final data = await _api.getData<Map<String, dynamic>>(
      '/api/v1/invites/overview',
      parser: (json) => json as Map<String, dynamic>,
    );
    return InviteOverview.fromJson(data);
  }
}
