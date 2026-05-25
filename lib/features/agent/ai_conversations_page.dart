import 'package:flutter/material.dart';
import 'package:soulfood_front/features/agent/agent_repository.dart';
import 'package:soulfood_front/features/agent/ai_chat_page.dart';

class AiConversationsPage extends StatefulWidget {
  const AiConversationsPage({super.key});

  @override
  State<AiConversationsPage> createState() => _AiConversationsPageState();
}

class _AiConversationsPageState extends State<AiConversationsPage> {
  final _agent = AgentRepository();
  List<AiConversationItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await _agent.listConversations();
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(AiConversationItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除对话'),
        content: Text('确定删除「${item.title}」？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _agent.clearConversation(item.id);
      if (mounted) {
        setState(() => _items.removeWhere((e) => e.id == item.id));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  void _openChat({String? conversationId, bool isNew = false}) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AiChatPage(conversationId: conversationId, isNewChat: isNew),
      ),
    ).then((_) => _load());
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.month}/${time.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 对话记录'),
        actions: [
          IconButton(
            onPressed: () => _openChat(isNew: true),
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: '新对话',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openChat(isNew: true),
        backgroundColor: const Color(0xFFFF8A43),
        icon: const Icon(Icons.chat),
        label: const Text('新对话'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _items.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(
                          height: 240,
                          child: Center(
                            child: Text(
                              '暂无对话记录\n从首页或下方按钮开始新对话',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFF8D919A)),
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Card(
                          key: ValueKey(item.id),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFEEF4FF),
                              child: const Icon(Icons.smart_toy_outlined, color: Color(0xFF2B5EA8)),
                            ),
                            title: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              item.preview.isEmpty ? '暂无消息' : item.preview,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatTime(item.updatedAt),
                                  style: const TextStyle(color: Color(0xFF8D919A), fontSize: 12),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20),
                                  onPressed: () => _delete(item),
                                ),
                              ],
                            ),
                            onTap: () => _openChat(conversationId: item.id),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
