import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:soulfood_front/features/favorite/favorite_repository.dart';

class AiReplyDetailPage extends StatelessWidget {
  const AiReplyDetailPage({super.key, required this.item});

  final FavoriteItem item;

  static final _markdownStyle = MarkdownStyleSheet(
    p: const TextStyle(color: Color(0xFF1E1F23), height: 1.5, fontSize: 15),
    strong: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E1F23)),
    listBullet: const TextStyle(color: Color(0xFF1E1F23), fontSize: 15),
    listIndent: 22,
    blockSpacing: 10,
  );

  @override
  Widget build(BuildContext context) {
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
                style: const TextStyle(color: Color(0xFF8D919A), fontSize: 12),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEDF0F6)),
            ),
            child: MarkdownBody(
              data: body,
              selectable: true,
              styleSheet: _markdownStyle,
            ),
          ),
        ],
      ),
    );
  }
}
