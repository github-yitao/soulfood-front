import 'package:soulfood_front/features/agent/agent_repository.dart';
import 'package:soulfood_front/features/room/room_join_link.dart';
import 'package:soulfood_front/features/room/room_models.dart';

/// 投票结果分享卡所需数据。
class VoteShareData {
  const VoteShareData({
    required this.voteResult,
    this.roomCode,
    this.roomTopic,
    this.recipes = const [],
    this.preferenceText,
    this.ghoul = false,
  });

  final RoomResult voteResult;
  final String? roomCode;
  final String? roomTopic;
  final List<RecipeItem> recipes;
  final String? preferenceText;
  final bool ghoul;

  List<RecipeItem> get topRecipes => recipes.take(3).toList();

  String get headline => ghoul ? '今夜喰食' : '今晚吃了啥';

  String get brandLabel => ghoul ? 'DecideMeal · 喰' : 'DecideMeal';

  String buildShareText() {
    final buffer = StringBuffer();
    buffer.writeln('$headline · $brandLabel');
    if (roomTopic != null && roomTopic!.trim().isNotEmpty) {
      buffer.writeln('主题：${roomTopic!.trim()}');
    }
    buffer.writeln(
      '胜出：${voteResult.title}（${voteResult.voteCount} 票 · ${voteResult.percent}%）',
    );
    if (topRecipes.isNotEmpty) {
      buffer.write('AI 推荐：');
      buffer.writeln(topRecipes.map((e) => e.name).join('、'));
    }
    if (preferenceText != null && preferenceText!.trim().isNotEmpty) {
      buffer.writeln('口味：${preferenceText!.trim()}');
    }
    if (roomCode != null && roomCode!.isNotEmpty) {
      buffer.writeln(RoomJoinLink.shareMessage(roomCode!));
    } else {
      buffer.writeln('一起来用 DecideMeal 决定今晚吃什么！');
    }
    return buffer.toString().trim();
  }
}
