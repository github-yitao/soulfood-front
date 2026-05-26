import 'package:soulfood_front/features/agent/agent_repository.dart';
import 'package:soulfood_front/features/room/room_models.dart';
import 'package:soulfood_front/features/room/share/vote_share_data.dart';

/// 好友聊天中的投票分享卡结构化载荷。
class VoteSharePayload {
  const VoteSharePayload({
    required this.winnerTitle,
    required this.voteCount,
    required this.percent,
    this.roomCode,
    this.roomTopic,
    this.preferenceText,
    this.ghoul = false,
    this.recipes = const [],
  });

  final String? roomCode;
  final String? roomTopic;
  final String winnerTitle;
  final int voteCount;
  final int percent;
  final String? preferenceText;
  final bool ghoul;
  final List<RecipeItem> recipes;

  List<RecipeItem> get topRecipes => recipes.take(3).toList();

  factory VoteSharePayload.fromJson(Map<String, dynamic> json) {
    final rawRecipes = json['recipes'] as List<dynamic>? ?? const [];
    return VoteSharePayload(
      roomCode: json['roomCode'] as String?,
      roomTopic: json['roomTopic'] as String?,
      winnerTitle: json['winnerTitle'] as String? ?? '',
      voteCount: (json['voteCount'] as num?)?.toInt() ?? 0,
      percent: (json['percent'] as num?)?.toInt() ?? 0,
      preferenceText: json['preferenceText'] as String?,
      ghoul: json['ghoul'] as bool? ?? false,
      recipes: rawRecipes
          .map((e) => RecipeItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (roomCode != null && roomCode!.isNotEmpty) 'roomCode': roomCode,
        if (roomTopic != null && roomTopic!.isNotEmpty) 'roomTopic': roomTopic,
        'winnerTitle': winnerTitle,
        'voteCount': voteCount,
        'percent': percent,
        if (preferenceText != null && preferenceText!.isNotEmpty) 'preferenceText': preferenceText,
        'ghoul': ghoul,
        'recipes': recipes
            .map(
              (e) => {
                'name': e.name,
                'score': e.score,
                'reason': e.reason,
              },
            )
            .toList(),
      };

  VoteShareData toVoteShareData() => VoteShareData(
        voteResult: RoomResult(
          optionId: 0,
          title: winnerTitle,
          voteCount: voteCount,
          percent: percent,
        ),
        roomCode: roomCode,
        roomTopic: roomTopic,
        recipes: recipes,
        preferenceText: preferenceText,
        ghoul: ghoul,
      );

  static VoteSharePayload fromVoteShareData(VoteShareData data) => VoteSharePayload(
        roomCode: data.roomCode,
        roomTopic: data.roomTopic,
        winnerTitle: data.voteResult.title,
        voteCount: data.voteResult.voteCount,
        percent: data.voteResult.percent,
        preferenceText: data.preferenceText,
        ghoul: data.ghoul,
        recipes: data.recipes,
      );
}
