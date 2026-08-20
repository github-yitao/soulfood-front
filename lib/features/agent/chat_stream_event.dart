import 'package:soulfood_front/features/agent/agent_repository.dart';

class ChatStreamAccumulator {
  String replyText = '';
  List<ChatActionCard> cards = [];
  WorkflowSnapshot? workflow;
  String? conversationId;

  void apply(
    Map<String, dynamic> event, {
    String Function(String text)? rewriteReply,
  }) {
    final type = event['type'] as String? ?? '';
    if (type == 'workflow' || type == 'step') {
      workflow = WorkflowSnapshot.merge(workflow, event);
      return;
    }
    if (type == 'chunk') {
      final piece = event['text'] as String? ?? '';
      if (piece.isEmpty) {
        return;
      }
      replyText += piece;
      if (rewriteReply != null) {
        replyText = rewriteReply(replyText);
      }
      return;
    }
    if (type == 'cards') {
      final rawCards = event['items'] as List<dynamic>? ?? [];
      cards = rawCards
          .map((e) => ChatActionCard.fromJson(e as Map<String, dynamic>))
          .toList();
      return;
    }
    if (type == 'done') {
      conversationId = event['conversationId'] as String? ?? conversationId;
      final rawCards = event['cards'] as List<dynamic>? ?? [];
      if (rawCards.isNotEmpty) {
        cards = rawCards
            .map((e) => ChatActionCard.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
  }
}
