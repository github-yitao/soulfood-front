import 'package:flutter/material.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/features/room/pages/recipe_result_page.dart';
import 'package:soulfood_front/features/room/share/vote_share_payload.dart';
import 'package:soulfood_front/features/room/widgets/vote_option_thumb.dart';

/// 聊天中的投票结果分享卡气泡（紧凑版）。
class VoteShareChatBubble extends StatelessWidget {
  const VoteShareChatBubble({
    super.key,
    required this.payload,
    required this.isMine,
  });

  final VoteSharePayload payload;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final ghoul = payload.ghoul;
    final accent = ghoul ? const Color(0xFFFF3B30) : colors.accent;
    final surface = isMine
        ? (ghoul ? const Color(0xFF3A2020) : colors.accent.withValues(alpha: 0.92))
        : (ghoul ? const Color(0xFF252528) : colors.cardBackground);
    final onSurface = isMine ? colors.onAccent : colors.textPrimary;
    final muted = isMine ? colors.onAccent.withValues(alpha: 0.85) : colors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDetail(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 268,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isMine ? Colors.transparent : (ghoul ? const Color(0xFF4A4A48) : colors.cardBorder),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.how_to_vote_rounded, size: 16, color: accent),
                  const SizedBox(width: 6),
                  Text(
                    ghoul ? '喰迹 · 投票结果' : '投票结果',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: accent),
                  ),
                ],
              ),
              if (payload.roomTopic != null && payload.roomTopic!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  payload.roomTopic!.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: muted),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  VoteOptionThumb(title: payload.winnerTitle),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payload.winnerTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: onSurface,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${payload.voteCount} 票 · ${payload.percent}% 胜出',
                          style: TextStyle(fontSize: 12, color: muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (payload.topRecipes.isNotEmpty) ...[
                const SizedBox(height: 10),
                ...payload.topRecipes.take(2).map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '· ${r.name} ${r.score}分',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: muted),
                        ),
                      ),
                    ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '点击查看详情',
                    style: TextStyle(fontSize: 11, color: accent, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 16, color: accent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    final data = payload.toVoteShareData();
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => RecipeResultPage(
          voteResult: data.voteResult,
          roomCode: data.roomCode,
          roomTopic: data.roomTopic,
          preference: data.preferenceText,
          initialRecipes: data.recipes,
        ),
      ),
    );
  }
}
