import 'package:flutter/material.dart';

class RecordItem {
  const RecordItem({
    required this.id,
    required this.recordType,
    required this.title,
    required this.detail,
    required this.dateText,
  });

  final int id;
  final String recordType;
  final String title;
  final String detail;
  final String dateText;

  /// 从 summary/detail 中解析「房间 123456」
  String? get roomCode {
    final match = RegExp(r'房间\s*(\d{6})').firstMatch(detail);
    return match?.group(1);
  }

  String get typeLabel {
    switch (recordType) {
      case 'vote':
        return '组局投票';
      case 'favorite':
        return '收藏';
      case 'eat':
        return '想去餐厅';
      case 'ai_recommend':
        return 'AI 推荐';
      default:
        return '记录';
    }
  }

  IconData get typeIcon {
    switch (recordType) {
      case 'vote':
        return Icons.how_to_vote_outlined;
      case 'favorite':
        return Icons.favorite_outline;
      case 'eat':
        return Icons.restaurant_outlined;
      case 'ai_recommend':
        return Icons.auto_awesome_outlined;
      default:
        return Icons.history;
    }
  }

  factory RecordItem.fromJson(Map<String, dynamic> json) {
    return RecordItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      recordType: json['recordType'] as String? ?? '',
      title: json['title'] as String? ?? '',
      detail: json['detail'] as String? ?? json['summary'] as String? ?? '',
      dateText: json['occurredAt'] as String? ?? '',
    );
  }
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

class RecordsData {
  const RecordsData({required this.stats, required this.records});

  const RecordsData.empty()
      : stats = const <RecordStat>[],
        records = const <RecordItem>[];

  final List<RecordStat> stats;
  final List<RecordItem> records;
}
