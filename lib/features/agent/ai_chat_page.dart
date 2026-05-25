import 'dart:async';

import 'package:flutter/material.dart';
import 'package:soulfood_front/features/agent/agent_repository.dart';
import 'package:soulfood_front/features/preference/preference_repository.dart';

class ChatMessage {
  ChatMessage({
    required this.text,
    required this.isUser,
    this.thinkingSeconds,
  });

  final String text;
  final bool isUser;
  /// AI 回复耗时（秒），保留两位小数展示
  final double? thinkingSeconds;
}

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final _agent = AgentRepository();
  final _prefRepo = PreferenceRepository();
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  final List<ChatMessage> _messages = [];
  String? _conversationId;
  bool _sending = false;
  bool _prefLoaded = false;
  String _preferenceText = '';
  double _thinkingElapsed = 0;
  Timer? _thinkingTimer;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    _conversationId = await _agent.loadConversationId();
    try {
      _preferenceText = await _prefRepo.preferenceText();
    } catch (_) {
      _preferenceText = '清淡、家常菜';
    }
    if (mounted) {
      setState(() {
        _prefLoaded = true;
        if (_messages.isEmpty) {
          _messages.add(
            ChatMessage(
              text: '你好，我是 DecideMeal 美食助手。'
                  '你可以问我「今晚吃什么」「微辣家常菜推荐」等问题。'
                  '${_preferenceText.isNotEmpty ? '\n\n已读取你的偏好：$_preferenceText' : ''}',
              isUser: false,
            ),
          );
        }
      });
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
            onPressed: _sending ? null : _clearChat,
            icon: const Icon(Icons.delete_outline),
            tooltip: '清空对话',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: !_prefLoaded
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
                      return _Bubble(message: msg);
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
  const _Bubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
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
            Text(
              message.text,
              style: TextStyle(
                color: isUser ? Colors.white : const Color(0xFF1E1F23),
                height: 1.45,
              ),
            ),
            if (!isUser && message.thinkingSeconds != null) ...[
              const SizedBox(height: 6),
              Text(
                '思考 ${_formatThinking(message.thinkingSeconds!)}',
                style: TextStyle(
                  fontSize: 11,
                  color: isUser ? Colors.white70 : const Color(0xFF8D919A),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

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
