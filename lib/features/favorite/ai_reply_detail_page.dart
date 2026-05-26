import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/core/theme/theme_widgets.dart';
import 'package:soulfood_front/features/favorite/favorite_repository.dart';

class AiReplyDetailPage extends StatelessWidget {
  const AiReplyDetailPage({super.key, required this.item});

  final FavoriteItem item;

  MarkdownStyleSheet _markdownStyle(AppSemanticColors colors) => MarkdownStyleSheet(
        p: TextStyle(color: colors.textPrimary, height: 1.5, fontSize: 15),
        strong: TextStyle(fontWeight: FontWeight.w800, color: colors.textPrimary),
        listBullet: TextStyle(color: colors.textPrimary, fontSize: 15),
        listIndent: 22,
        blockSpacing: 10,
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final body = item.content ?? item.subtitle ?? '暂无内容';
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (item.conversationId != null && item.conversationId!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '来自 AI 对话',
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: appCardDecoration(context),
            child: MarkdownBody(
              data: body,
              selectable: true,
              styleSheet: _markdownStyle(colors),
            ),
          ),
        ],
      ),
    );
  }
}
