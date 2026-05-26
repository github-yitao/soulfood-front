import 'package:flutter/material.dart';
import 'package:soulfood_front/core/api/api_client.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/features/friend_chat/friend_chat_models.dart';
import 'package:soulfood_front/features/friend_chat/friend_chat_repository.dart';
import 'package:soulfood_front/features/friend_chat/friend_chat_websocket.dart';
import 'package:soulfood_front/features/friend_chat/vote_share_chat_bubble.dart';

class FriendChatArgs {
  const FriendChatArgs({
    required this.friendUserId,
    required this.nickname,
    this.avatarUrl,
  });

  final int friendUserId;
  final String nickname;
  final String? avatarUrl;
}

class FriendChatPage extends StatefulWidget {
  const FriendChatPage({super.key, required this.args});

  final FriendChatArgs args;

  @override
  State<FriendChatPage> createState() => _FriendChatPageState();
}

class _FriendChatPageState extends State<FriendChatPage> {
  final _repo = FriendChatRepository();
  final _ws = FriendChatWebSocketClient();
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  int? _conversationId;
  String _peerNickname = '';
  String? _peerAvatarUrl;
  bool _loading = true;
  bool _sending = false;
  String? _error;
  bool _wsConnected = false;
  final List<FriendChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _peerNickname = widget.args.nickname;
    _peerAvatarUrl = widget.args.avatarUrl;
    _bootstrap();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _ws.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final conversation = await _repo.openConversation(widget.args.friendUserId);
      final messages = await _repo.listMessages(conversationId: conversation.conversationId);
      await _repo.markRead(conversation.conversationId);
      if (!mounted) return;
      setState(() {
        _conversationId = conversation.conversationId;
        _peerNickname = conversation.peerNickname;
        _peerAvatarUrl = conversation.peerAvatarUrl;
        _messages
          ..clear()
          ..addAll(messages);
        _loading = false;
      });
      _connectWs(conversation.conversationId);
      _scrollToBottom();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = '加载失败，请稍后重试';
        _loading = false;
      });
    }
  }

  void _connectWs(int conversationId) {
    final token = AppServices.I.session.accessToken;
    if (token == null || token.isEmpty) return;
    _ws.connect(
      conversationId: conversationId,
      token: token,
      onMessage: _onWsMessage,
      onConnectionChanged: (connected) {
        if (!mounted) return;
        setState(() => _wsConnected = connected);
      },
    );
  }

  void _onWsMessage(FriendChatMessage message) {
    if (!mounted) return;
    final myId = AppServices.I.session.userId;
    final normalized = FriendChatMessage(
      id: message.id,
      conversationId: message.conversationId,
      senderId: message.senderId,
      messageType: message.messageType,
      content: message.content,
      createdAt: message.createdAt,
      mine: myId != null && message.senderId == myId,
      voteShare: message.voteShare,
    );
    if (_messages.any((m) => m.id == normalized.id)) return;
    setState(() {
      _messages.add(normalized);
    });
    final conversationId = _conversationId;
    if (conversationId != null && !normalized.mine) {
      _repo.markRead(conversationId);
    }
    _scrollToBottom();
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    final conversationId = _conversationId;
    if (text.isEmpty || conversationId == null || _sending) return;

    setState(() => _sending = true);
    _inputCtrl.clear();
    try {
      final message = await _repo.sendMessage(conversationId: conversationId, content: text);
      if (!mounted) return;
      if (!_messages.any((m) => m.id == message.id)) {
        setState(() => _messages.add(message));
      }
      _scrollToBottom();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
        _inputCtrl.text = text;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
        _inputCtrl.text = text;
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: colors.infoBackground,
              backgroundImage: _peerAvatarUrl != null && _peerAvatarUrl!.isNotEmpty
                  ? NetworkImage(_peerAvatarUrl!)
                  : null,
              child: _peerAvatarUrl == null || _peerAvatarUrl!.isEmpty
                  ? Text(
                      _peerNickname.isNotEmpty ? _peerNickname.substring(0, 1) : '?',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.infoText),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_peerNickname, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  Text(
                    _wsConnected ? '在线' : '连接中…',
                    style: TextStyle(fontSize: 11, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: colors.errorText)),
                              const SizedBox(height: 12),
                              OutlinedButton(onPressed: _bootstrap, child: const Text('重试')),
                            ],
                          ),
                        ),
                      )
                    : _messages.isEmpty
                        ? Center(
                            child: Text(
                              '和 $_peerNickname 打个招呼吧',
                              style: TextStyle(color: colors.textSecondary),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollCtrl,
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              return _MessageBubble(message: message);
                            },
                          ),
          ),
          _Composer(
            controller: _inputCtrl,
            sending: _sending,
            enabled: !_loading && _error == null,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final FriendChatMessage message;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isMine = message.mine;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.isVoteShare)
              VoteShareChatBubble(payload: message.voteShare!, isMine: isMine)
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMine ? colors.accent : colors.cardBackground,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMine ? 16 : 4),
                      bottomRight: Radius.circular(isMine ? 4 : 16),
                    ),
                    border: isMine ? null : Border.all(color: colors.cardBorder),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isMine ? colors.onAccent : colors.textPrimary,
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
            if (message.createdAt.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                message.createdAt,
                style: TextStyle(fontSize: 11, color: colors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.sending,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: colors.cardBorder)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled && !sending,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: '发消息…',
                  filled: true,
                  fillColor: colors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(color: colors.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(color: colors.cardBorder),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: enabled && !sending ? onSend : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size(48, 48),
                shape: const CircleBorder(),
                padding: EdgeInsets.zero,
              ),
              child: sending
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: colors.onAccent),
                    )
                  : Icon(Icons.send_rounded, color: colors.onAccent, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
