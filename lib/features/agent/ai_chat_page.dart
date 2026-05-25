import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:soulfood_front/features/agent/agent_repository.dart';
import 'package:soulfood_front/features/agent/ai_conversations_page.dart';
import 'package:soulfood_front/features/favorite/favorite_repository.dart';
import 'package:soulfood_front/features/preference/preference_repository.dart';

class ChatMessage {
  ChatMessage({
    required this.text,
    required this.isUser,
    this.thinkingSeconds,
    this.favorited = false,
  });

  final String text;
  final bool isUser;
  final double? thinkingSeconds;
  final bool favorited;
}

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key, this.conversationId, this.isNewChat = false});

  final String? conversationId;
  final bool isNewChat;

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final _agent = AgentRepository();
  final _prefRepo = PreferenceRepository();
  final _favRepo = FavoriteRepository();
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  final List<ChatMessage> _messages = [];
  String? _conversationId;
  bool _sending = false;
  bool _prefLoaded = false;
  bool _historyLoaded = false;
  String _preferenceText = '';
  double _thinkingElapsed = 0;
  Timer? _thinkingTimer;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    if (widget.isNewChat) {
      _conversationId = null;
    } else if (widget.conversationId != null && widget.conversationId!.isNotEmpty) {
      _conversationId = widget.conversationId;
    } else {
      _conversationId = await _agent.loadConversationId();
    }

    try {
      _preferenceText = await _prefRepo.preferenceText();
    } catch (_) {
      _preferenceText = '清淡、家常菜';
    }

    if (_conversationId != null && _conversationId!.isNotEmpty) {
      await _loadHistory();
    } else {
      _addWelcomeMessage();
    }

    if (mounted) {
      setState(() {
        _prefLoaded = true;
        _historyLoaded = true;
      });
    }
  }

  void _addWelcomeMessage() {
    if (_messages.isNotEmpty) return;
    _messages.add(
      ChatMessage(
        text: '你好，我是 DecideMeal 美食助手。'
            '你可以问我「今晚吃什么」「微辣家常菜推荐」等问题。'
            '${_preferenceText.isNotEmpty ? '\n\n已读取你的偏好：$_preferenceText' : ''}',
        isUser: false,
      ),
    );
  }

  Future<void> _loadHistory() async {
    final id = _conversationId;
    if (id == null || id.isEmpty) return;
    try {
      final history = await _agent.loadHistory(id);
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(
            history.map(
              (m) => ChatMessage(
                text: m.content,
                isUser: m.role == 'user',
              ),
            ),
          );
      });
      if (_messages.isEmpty) _addWelcomeMessage();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('加载历史失败：$e')));
        _addWelcomeMessage();
      }
    }
  }

  @override
  void dispose() {
    _thinkingTimer?.cancel();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _startThinkingTimer(Stopwatch stopwatch) {
    _thinkingElapsed = 0;
    _thinkingTimer?.cancel();
    _thinkingTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted) return;
      setState(() => _thinkingElapsed = stopwatch.elapsedMilliseconds / 1000);
    });
  }

  void _stopThinkingTimer() {
    _thinkingTimer?.cancel();
    _thinkingTimer = null;
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _sending = true;
      _messages.add(ChatMessage(text: text, isUser: true));
      _inputCtrl.clear();
    });
    final stopwatch = Stopwatch()..start();
    _startThinkingTimer(stopwatch);
    _scrollToBottom();

    try {
      final reply = await _agent.chat(
        message: text,
        conversationId: _conversationId,
      );
      stopwatch.stop();
      final thinkingSeconds = stopwatch.elapsedMilliseconds / 1000;
      if (!mounted) return;
      setState(() {
        _conversationId = reply.conversationId;
        _messages.add(
          ChatMessage(
            text: reply.reply,
            isUser: false,
            thinkingSeconds: thinkingSeconds,
          ),
        );
      });
      if (!widget.isNewChat && widget.conversationId == null) {
        await _agent.saveConversationId(reply.conversationId);
      }
      _scrollToBottom();
    } catch (e) {
      stopwatch.stop();
      final thinkingSeconds = stopwatch.elapsedMilliseconds / 1000;
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: '发送失败：$e',
              isUser: false,
              thinkingSeconds: thinkingSeconds,
            ),
          );
        });
      }
    } finally {
      _stopThinkingTimer();
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _favoriteReply(int index) async {
    final msg = _messages[index];
    if (msg.isUser || msg.favorited) return;
    try {
      await _favRepo.addAiReply(
        content: msg.text,
        conversationId: _conversationId,
      );
      if (mounted) {
        setState(() {
          _messages[index] = ChatMessage(
            text: msg.text,
            isUser: false,
            thinkingSeconds: msg.thinkingSeconds,
            favorited: true,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已收藏 AI 回复，可在「我的收藏」查看')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _clearChat() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空对话'),
        content: const Text('将清除当前会话记忆，确定继续？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('清空')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    if (_conversationId != null && _conversationId!.isNotEmpty) {
      try {
        await _agent.clearConversation(_conversationId!);
      } catch (_) {
        await _agent.saveConversationId(null);
      }
    } else {
      await _agent.saveConversationId(null);
    }

    if (!mounted) return;
    setState(() {
      _conversationId = null;
      _messages
        ..clear()
        ..add(
          ChatMessage(
            text: '会话已清空，可以重新开始提问。',
            isUser: false,
          ),
        );
    });
  }

  void _openConversations() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const AiConversationsPage()),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 美食助手'),
        actions: [
          IconButton(
            onPressed: _openConversations,
            icon: const Icon(Icons.history),
            tooltip: '对话记录',
          ),
          IconButton(
            onPressed: _sending ? null : _clearChat,
            icon: const Icon(Icons.delete_outline),
            tooltip: '清空对话',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: !_prefLoaded || !_historyLoaded
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: _messages.length + (_sending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_sending && index == _messages.length) {
                        return _ThinkingBubble(elapsed: _thinkingElapsed);
                      }
                      final msg = _messages[index];
                      return _Bubble(
                        message: msg,
                        onFavorite: !msg.isUser ? () => _favoriteReply(index) : null,
                      );
                    },
                  ),
          ),
          if (_sending)
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputCtrl,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: '问我吃什么、怎么做…',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _sending ? null : _send,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      padding: EdgeInsets.zero,
                      backgroundColor: const Color(0xFFFF8A43),
                      shape: const CircleBorder(),
                    ),
                    child: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, this.onFavorite});

  final ChatMessage message;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final maxWidth = MediaQuery.sizeOf(context).width * (isUser ? 0.78 : 0.92);
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFFF8A43) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isUser)
              Text(
                message.text,
                style: const TextStyle(color: Colors.white, height: 1.45),
              )
            else
              MarkdownBody(
                data: message.text,
                selectable: true,
                styleSheet: _assistantMarkdownStyle,
              ),
            if (!isUser) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  if (message.thinkingSeconds != null)
                    Text(
                      '思考 ${_formatThinking(message.thinkingSeconds!)}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF8D919A)),
                    ),
                  const Spacer(),
                  if (onFavorite != null)
                    InkWell(
                      onTap: message.favorited ? null : onFavorite,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          message.favorited ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: message.favorited
                              ? const Color(0xFFFF7A22)
                              : const Color(0xFF8D919A),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static final MarkdownStyleSheet _assistantMarkdownStyle = MarkdownStyleSheet(
    p: const TextStyle(color: Color(0xFF1E1F23), height: 1.5, fontSize: 15),
    strong: const TextStyle(
      fontWeight: FontWeight.w800,
      color: Color(0xFF1E1F23),
    ),
    em: const TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF1E1F23)),
    h1: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E1F23)),
    h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E1F23)),
    h3: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E1F23)),
    listBullet: const TextStyle(color: Color(0xFF1E1F23), fontSize: 15),
    listIndent: 22,
    blockSpacing: 10,
    horizontalRuleDecoration: BoxDecoration(
      border: Border(top: BorderSide(color: Color(0xFFE8EBF0))),
    ),
  );

  static String _formatThinking(double seconds) => '${seconds.toStringAsFixed(2)} 秒';
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble({required this.elapsed});

  final double elapsed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(
              '思考中 ${elapsed.toStringAsFixed(2)} 秒',
              style: const TextStyle(color: Color(0xFF8D919A), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
