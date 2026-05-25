import 'dart:async';

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
  final _searchCtrl = TextEditingController();
  Timer? _searchDebounce;

  List<AiConversationItem> _items = [];
  bool _loading = true;
  String? _sceneTag;

  static const _sceneTags = ['聚餐', '减脂', '探店', '日常'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await _agent.listConversations(
        keyword: _searchCtrl.text.trim(),
        sceneTag: _sceneTag,
      );
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), _load);
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

  Future<void> _rename(AiConversationItem item) async {
    final ctrl = TextEditingController(text: item.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('重命名对话'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 64,
          decoration: const InputDecoration(hintText: '输入对话标题'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (newTitle == null || newTitle.isEmpty) return;
    try {
      await _agent.updateConversation(item.id, title: newTitle);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _setSceneTag(AiConversationItem item) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(title: Text('设置场景标签', style: TextStyle(fontWeight: FontWeight.w700))),
            ..._sceneTags.map(
              (tag) => ListTile(
                title: Text(tag),
                trailing: item.sceneTag == tag ? const Icon(Icons.check, color: Color(0xFF2B5EA8)) : null,
                onTap: () => Navigator.pop(ctx, tag),
              ),
            ),
            ListTile(
              title: const Text('清除标签'),
              onTap: () => Navigator.pop(ctx, ''),
            ),
          ],
        ),
      ),
    );
    if (selected == null) return;
    try {
      await _agent.updateConversation(item.id, sceneTag: selected);
      await _load();
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (value) {
                setState(() {});
                _onSearchChanged(value);
              },
              decoration: InputDecoration(
                hintText: '搜索对话标题或内容…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _load();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('全部'),
                    selected: _sceneTag == null,
                    onSelected: (_) {
                      setState(() => _sceneTag = null);
                      _load();
                    },
                  ),
                ),
                ..._sceneTags.map(
                  (tag) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(tag),
                      selected: _sceneTag == tag,
                      onSelected: (_) {
                        setState(() => _sceneTag = tag);
                        _load();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
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
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      if (item.sceneTag != null && item.sceneTag!.isNotEmpty)
                                        Container(
                                          margin: const EdgeInsets.only(left: 6),
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEEF4FF),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            item.sceneTag!,
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF2B5EA8)),
                                          ),
                                        ),
                                    ],
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
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert, size: 20),
                                        onSelected: (value) {
                                          switch (value) {
                                            case 'rename':
                                              _rename(item);
                                            case 'tag':
                                              _setSceneTag(item);
                                            case 'delete':
                                              _delete(item);
                                          }
                                        },
                                        itemBuilder: (_) => const [
                                          PopupMenuItem(value: 'rename', child: Text('重命名')),
                                          PopupMenuItem(value: 'tag', child: Text('设置标签')),
                                          PopupMenuItem(value: 'delete', child: Text('删除')),
                                        ],
                                      ),
                                    ],
                                  ),
                                  onTap: () => _openChat(conversationId: item.id),
                                  onLongPress: () => _rename(item),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
