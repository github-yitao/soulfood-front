class RoomOption {
  RoomOption({
    required this.id,
    required this.title,
    required this.voteCount,
    required this.percent,
    required this.source,
  });

  final int id;
  final String title;
  final int voteCount;
  final int percent;
  final String source;

  factory RoomOption.fromJson(Map<String, dynamic> json) {
    return RoomOption(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      voteCount: (json['voteCount'] as num?)?.toInt() ?? 0,
      percent: (json['percent'] as num?)?.toInt() ?? 0,
      source: json['source'] as String? ?? 'manual',
    );
  }
}

class RoomDetail {
  RoomDetail({
    required this.code,
    required this.topic,
    required this.status,
    required this.participantCount,
    required this.myVoteOptionId,
    required this.options,
    this.durationMin,
    this.expiresAt,
    this.remainingSeconds = 0,
  });

  final String code;
  final String topic;
  final String status;
  final int participantCount;
  final int? durationMin;
  final int? myVoteOptionId;
  final String? expiresAt;
  final int remainingSeconds;
  final List<RoomOption> options;

  bool get isClosed => status == 'closed';

  factory RoomDetail.fromJson(Map<String, dynamic> json) {
    final list = json['options'] as List<dynamic>? ?? [];
    return RoomDetail(
      code: json['code'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
      status: json['status'] as String? ?? '',
      participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
      durationMin: (json['durationMin'] as num?)?.toInt(),
      myVoteOptionId: (json['myVoteOptionId'] as num?)?.toInt(),
      expiresAt: json['expiresAt'] as String?,
      remainingSeconds: (json['remainingSeconds'] as num?)?.toInt() ?? 0,
      options: list
          .map((e) => RoomOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RoomResult {
  RoomResult({
    required this.optionId,
    required this.title,
    required this.voteCount,
    required this.percent,
  });

  final int optionId;
  final String title;
  final int voteCount;
  final int percent;

  factory RoomResult.fromJson(Map<String, dynamic> json) {
    return RoomResult(
      optionId: (json['optionId'] as num).toInt(),
      title: json['title'] as String? ?? '',
      voteCount: (json['voteCount'] as num?)?.toInt() ?? 0,
      percent: (json['percent'] as num?)?.toInt() ?? 0,
    );
  }
}

class FriendRoom {
  FriendRoom({
    required this.code,
    required this.topic,
    required this.status,
    required this.ownerId,
    required this.ownerNickname,
    required this.participantCount,
    required this.createdAt,
  });

  final String code;
  final String topic;
  final String status;
  final int ownerId;
  final String ownerNickname;
  final int participantCount;
  final String createdAt;

  factory FriendRoom.fromJson(Map<String, dynamic> json) {
    return FriendRoom(
      code: json['code'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
      status: json['status'] as String? ?? '',
      ownerId: (json['ownerId'] as num?)?.toInt() ?? 0,
      ownerNickname: json['ownerNickname'] as String? ?? '好友',
      participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}
