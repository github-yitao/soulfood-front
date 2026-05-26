import 'package:flutter/material.dart';
import 'package:soulfood_front/core/theme/ghoul_eye_mark.dart';
import 'package:soulfood_front/features/agent/agent_repository.dart';
import 'package:soulfood_front/features/room/share/vote_share_data.dart';
import 'package:soulfood_front/features/room/widgets/vote_option_thumb.dart';

/// 固定尺寸分享图（340×520），用于 RepaintBoundary 导出。
class VoteShareCardWidget extends StatelessWidget {
  const VoteShareCardWidget({
    super.key,
    required this.data,
  });

  static const double cardWidth = 340;
  static const double cardHeight = 520;

  final VoteShareData data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: data.ghoul ? _GhoulCard(data: data) : _ClassicCard(data: data),
    );
  }
}

class _ClassicCard extends StatelessWidget {
  const _ClassicCard({required this.data});

  final VoteShareData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF8F0), Color(0xFFFFE8D0)],
        ),
        border: Border.all(color: const Color(0xFFFFD4A8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8A43).withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          child: _CardBody(
            data: data,
            accent: const Color(0xFFFF8A43),
            textPrimary: const Color(0xFF1F2430),
            textSecondary: const Color(0xFF6F7888),
            chipBg: const Color(0xFFFFF2E0),
            chipBorder: const Color(0xFFFFD4A8),
            divider: const Color(0xFFECEFF3),
            footer: '和朋友一起，更快决定吃什么',
          ),
        ),
      ),
    );
  }
}

class _GhoulCard extends StatelessWidget {
  const _GhoulCard({required this.data});

  final VoteShareData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C1C1E), Color(0xFF252528)],
        ),
        border: Border.all(color: const Color(0xFF4A4A48)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF3B30).withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              right: -12,
              top: -8,
              child: Opacity(
                opacity: 0.35,
                child: GhoulEyeMark(size: 120, glow: true),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
              child: _CardBody(
                data: data,
                accent: const Color(0xFFFF3B30),
                textPrimary: const Color(0xFFF4ECEC),
                textSecondary: const Color(0xFFB8A8A8),
                chipBg: const Color(0x33FF3B30),
                chipBorder: const Color(0x66FF3B30),
                divider: const Color(0xFF3A3A3E),
                footer: '在饥饿与纠结之间，选出今晚的归宿',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.data,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.chipBg,
    required this.chipBorder,
    required this.divider,
    required this.footer,
  });

  final VoteShareData data;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Color chipBg;
  final Color chipBorder;
  final Color divider;
  final String footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: chipBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.how_to_vote_rounded, size: 14, color: accent),
                  const SizedBox(width: 4),
                  Text(
                    data.headline,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: accent),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              data.brandLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        if (data.roomTopic != null && data.roomTopic!.trim().isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            data.roomTopic!.trim(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textSecondary,
              height: 1.3,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VoteOptionThumb(title: data.voteResult.title),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.voteResult.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${data.voteResult.voteCount} 票 · ${data.voteResult.percent}% 胜出',
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                  if (data.roomCode != null && data.roomCode!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '房间 ${data.roomCode}',
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'AI 推荐菜谱',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textPrimary),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: data.topRecipes.isEmpty
              ? Center(
                  child: Text(
                    '菜谱生成中…',
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                )
              : ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.topRecipes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = data.topRecipes[index];
                    return _RecipeRow(
                      item: item,
                      index: index + 1,
                      accent: accent,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      surface: chipBg,
                      border: chipBorder,
                    );
                  },
                ),
        ),
        Divider(color: divider, height: 1),
        const SizedBox(height: 10),
        Text(
          footer,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11, color: textSecondary, height: 1.35),
        ),
      ],
    );
  }
}

class _RecipeRow extends StatelessWidget {
  const _RecipeRow({
    required this.item,
    required this.index,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.surface,
    required this.border,
  });

  final RecipeItem item;
  final int index;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Text(
              '$index',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: accent),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary),
                ),
                if (item.reason.isNotEmpty)
                  Text(
                    item.reason,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: textSecondary),
                  ),
              ],
            ),
          ),
          Text(
            '${item.score}分',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: accent),
          ),
        ],
      ),
    );
  }
}
