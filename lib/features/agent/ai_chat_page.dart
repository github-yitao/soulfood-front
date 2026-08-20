import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:soulfood_front/core/location/location_service.dart';
import 'package:soulfood_front/core/theme/app_semantic_colors.dart';
import 'package:soulfood_front/features/agent/agent_repository.dart';
import 'package:soulfood_front/features/agent/ai_conversations_page.dart';
import 'package:soulfood_front/features/agent/ai_memory_page.dart';
import 'package:soulfood_front/features/agent/chat_stream_event.dart';
import 'package:soulfood_front/features/agent/workflow_card.dart';
import 'package:soulfood_front/features/favorite/favorite_repository.dart';
import 'package:soulfood_front/features/nearby/nearby_repository.dart';
import 'package:soulfood_front/features/nearby/restaurant_detail_page.dart';
import 'package:soulfood_front/features/preference/preference_repository.dart';
import 'package:soulfood_front/features/recipe/recipe_detail_page.dart';
import 'package:soulfood_front/features/room/room_repository.dart';
import 'package:soulfood_front/routing/app_routes.dart';

class ChatMessage {
  ChatMessage({
    required this.text,
    required this.isUser,
    this.thinkingSeconds,
    this.favorited = false,
    this.cards = const [],
    this.workflow,
    this.streaming = false,
    this.imagePath,
  });

  final String text;
  final bool isUser;
  final double? thinkingSeconds;
  final bool favorited;
  final List<ChatActionCard> cards;
  final WorkflowSnapshot? workflow;
  final bool streaming;
  final String? imagePath;
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
  final _nearbyRepo = NearbyRepository();
  final _roomRepo = RoomRepository();
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  final List<ChatMessage> _messages = [];
  String? _conversationId;
  bool _sending = false;
  bool _prefLoaded = false;
  bool _loadingOlder = false;
  bool _historyHasMore = true;
  int _historyOffset = 0;
  String _preferenceText = '';
  double _thinkingElapsed = 0;
  Timer? _thinkingTimer;
  UserLocation? _location;
  XFile? _pendingImage;
  final _imagePicker = ImagePicker();

  static const _quickPrompts = ['今晚吃什么？', '三人聚餐推荐', '20分钟快手菜', '附近有什么好吃的'];

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    if (widget.isNewChat) {
      _conversationId = null;
    } else if (widget.conversationId != null &&
        widget.conversationId!.isNotEmpty) {
      _conversationId = widget.conversationId;
    } else {
      _conversationId = await _agent.loadConversationId();
    }

    final prefFuture = _prefRepo
        .preferenceText()
        .timeout(const Duration(seconds: 3), onTimeout: () => '清淡、家常菜')
        .catchError((_) => '清淡、家常菜');
    final locationFuture = LocationService.current()
        .timeout(const Duration(seconds: 3), onTimeout: () => null)
        .catchError((_) => null);

    if (_conversationId != null && _conversationId!.isNotEmpty) {
      await _loadInitialHistory();
    } else {
      _addWelcomeMessage();
    }

    _preferenceText = await prefFuture;
    _location = await locationFuture;

    if (mounted) {
      setState(() {
        _prefLoaded = true;
      });
    }
  }

  void _addWelcomeMessage() {
    if (_messages.isNotEmpty) return;
    _messages.add(
      ChatMessage(
        text:
            '你好，我是 DecideMeal 美食助手。'
            '你可以问我「今晚吃什么」「微辣家常菜推荐」等问题。'
            '${_preferenceText.isNotEmpty ? '\n\n已结合你的偏好与位置个性化推荐。' : ''}',
        isUser: false,
      ),
    );
  }

  Future<void> _loadInitialHistory() async {
    final id = _conversationId;
    if (id == null || id.isEmpty) return;
    try {
      final history = await _agent
          .loadHistory(id, offset: 0, limit: 10)
          .timeout(const Duration(seconds: 6));
      if (!mounted) return;
      setState(() {
        _historyOffset = history.length;
        _historyHasMore = history.length == 10;
        _messages
          ..clear()
          ..addAll(
            history.map(
              (m) => ChatMessage(
                text: m.content,
                isUser: m.role == 'user',
                cards: m.cards,
                workflow: m.workflow,
              ),
            ),
          );
      });
      if (_messages.isEmpty) _addWelcomeMessage();
      _scrollToBottom();
    } catch (e) {
      // 本地缓存的会话可能已被删除或数据库已重置，静默开新对话
      await _agent.saveConversationId(null);
      if (mounted) {
        setState(() => _conversationId = null);
        _addWelcomeMessage();
        _historyHasMore = false;
      }
    }
  }

  Future<void> _loadOlderHistory() async {
    final id = _conversationId;
    if (id == null || id.isEmpty || _loadingOlder || !_historyHasMore) return;
    setState(() => _loadingOlder = true);
    try {
      final older = await _agent
          .loadHistory(id, offset: _historyOffset, limit: 10)
          .timeout(const Duration(seconds: 6));
      if (!mounted || older.isEmpty) {
        if (mounted) setState(() => _historyHasMore = false);
        return;
      }
      final mapped = older
          .map(
            (m) => ChatMessage(
              text: m.content,
              isUser: m.role == 'user',
              cards: m.cards,
              workflow: m.workflow,
            ),
          )
          .toList();
      setState(() {
        _messages.insertAll(0, mapped);
        _historyOffset += older.length;
        _historyHasMore = older.length == 10;
      });
    } catch (_) {
      // keep current list
    } finally {
      if (mounted) setState(() => _loadingOlder = false);
    }
  }

  @override
  void dispose() {
    _thinkingTimer?.cancel();
    _inputCtrl.dispose();
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    if (_scrollCtrl.position.pixels <= 24) {
      _loadOlderHistory();
    }
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

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _inputCtrl.text).trim();
    final pendingImage = _pendingImage;
    if ((text.isEmpty && pendingImage == null) || _sending) return;
    _sending = true;

    String? imageBase64;
    String? imageMimeType;
    String? imagePath;
    if (pendingImage != null) {
      try {
        imagePath = pendingImage.path;
        final bytes = await pendingImage.readAsBytes();
        imageBase64 = base64Encode(bytes);
        imageMimeType = pendingImage.mimeType ?? 'image/jpeg';
      } catch (e) {
        if (mounted) {
          setState(() => _sending = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('读图失败：$e')));
        } else {
          _sending = false;
        }
        return;
      }
    }

    if (preset == null) {
      _inputCtrl.clear();
    }
    setState(() => _pendingImage = null);

    final displayText = text.isNotEmpty
        ? text
        : (pendingImage != null ? '[图片] 请识别并推荐' : '');

    setState(() {
      _messages.add(
        ChatMessage(text: displayText, isUser: true, imagePath: imagePath),
      );
      _messages.add(ChatMessage(text: '', isUser: false, streaming: true));
    });
    final assistantIndex = _messages.length - 1;
    final stopwatch = Stopwatch()..start();
    _startThinkingTimer(stopwatch);
    _scrollToBottom();

    try {
      final acc = ChatStreamAccumulator();
      await for (final event in _agent.chatStream(
        message: text,
        conversationId: _conversationId,
        lat: _location?.lat,
        lng: _location?.lng,
        imageBase64: imageBase64,
        imageMimeType: imageMimeType,
      )) {
        acc.apply(
          event,
          rewriteReply: (current) => _stripReplayedPrevious(current, assistantIndex),
        );
        if (!mounted) return;
        setState(() {
          _messages[assistantIndex] = ChatMessage(
            text: acc.replyText,
            isUser: false,
            streaming: true,
            cards: acc.cards,
            workflow: acc.workflow,
          );
        });
        _scrollToBottom();
      }

      stopwatch.stop();
      final thinkingSeconds = stopwatch.elapsedMilliseconds / 1000;
      if (!mounted) return;
      if (acc.conversationId != null && acc.conversationId!.isNotEmpty) {
        _conversationId = acc.conversationId;
      }
      setState(() {
        _messages[assistantIndex] = ChatMessage(
          text: acc.replyText.isEmpty && acc.workflow == null
              ? '暂无回复'
              : acc.replyText,
          isUser: false,
          thinkingSeconds: thinkingSeconds,
          cards: acc.cards,
          workflow: acc.workflow,
        );
      });
      if (_conversationId != null &&
          _conversationId!.isNotEmpty &&
          !widget.isNewChat &&
          widget.conversationId == null) {
        await _agent.saveConversationId(_conversationId);
      }
      _scrollToBottom();
    } catch (e) {
      stopwatch.stop();
      final thinkingSeconds = stopwatch.elapsedMilliseconds / 1000;
      if (mounted) {
        setState(() {
          _messages[assistantIndex] = ChatMessage(
            text: '发送失败：$e',
            isUser: false,
            thinkingSeconds: thinkingSeconds,
          );
        });
      }
    } finally {
      _stopThinkingTimer();
      if (mounted) setState(() => _sending = false);
    }
  }

  String _stripReplayedPrevious(String reply, int assistantIndex) {
    ChatMessage? previous;
    for (var i = assistantIndex - 1; i >= 0; i--) {
      final msg = _messages[i];
      if (!msg.isUser && !msg.streaming && msg.text.trim().isNotEmpty) {
        previous = msg;
        break;
      }
    }
    if (previous == null) return reply;
    final previousText = previous.text.trim();
    if (previousText.length < 16) return reply;
    final current = reply.trimLeft();
    if (current.startsWith(previousText)) {
      return current.substring(previousText.length).trimLeft();
    }
    return reply;
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
            cards: msg.cards,
            workflow: msg.workflow,
          );
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已收藏 AI 回复，可在「我的收藏」查看')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
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
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('清空'),
          ),
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
        ..add(ChatMessage(text: '会话已清空，可以重新开始提问。', isUser: false));
    });
  }

  void _openMemory() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const AiMemoryPage()),
    );
  }

  Future<void> _continueWorkflow(ChatMessage msg, {bool skipPhoto = false}) async {
    final workflow = msg.workflow;
    final conversationId = _conversationId;
    if (workflow == null || conversationId == null || conversationId.isEmpty) {
      return;
    }
    WorkflowStep? waiting;
    for (final step in workflow.steps) {
      if (step.status == 'waiting') {
        waiting = step;
        break;
      }
    }
    if (waiting == null || _sending) return;

    String? imageBase64;
    String? imageMimeType;
    String? imagePath;
    double? continueLat;
    double? continueLng;
    if (waiting.id == 'vision' && !skipPhoto) {
      try {
        final file = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1280,
          imageQuality: 85,
        );
        if (file == null) return;
        imagePath = file.path;
        imageBase64 = base64Encode(await file.readAsBytes());
        imageMimeType = file.mimeType ?? 'image/jpeg';
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('选图失败：$e')));
        }
        return;
      }
    }
    if (waiting.id == 'locate') {
      try {
        final loc = await LocationService.current();
        continueLat = loc?.lat;
        continueLng = loc?.lng;
        _location = loc;
        if (continueLat == null || continueLng == null) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('还没有定位，请先授权位置')));
          }
          return;
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('定位失败：$e')));
        }
        return;
      }
    }

    setState(() => _sending = true);
    final displayText = switch (waiting.id) {
      'vision' => skipPhoto ? '不拍图，按食材做菜' : '[图片] 继续看图做菜',
      'locate' => '已开启定位，继续',
      _ => '确认这些选项并开房',
    };
    setState(() {
      _messages.add(
        ChatMessage(text: displayText, isUser: true, imagePath: imagePath),
      );
      _messages.add(ChatMessage(text: '', isUser: false, streaming: true));
    });
    final assistantIndex = _messages.length - 1;
    final stopwatch = Stopwatch()..start();
    _startThinkingTimer(stopwatch);
    _scrollToBottom();

    try {
      final acc = ChatStreamAccumulator();
      await for (final event in _agent.continueWorkflow(
        runId: workflow.runId,
        conversationId: conversationId,
        stepId: waiting.id,
        message: skipPhoto
            ? '不拍图'
            : (waiting.id == 'locate' ? '已定位，继续' : null),
        imageBase64: imageBase64,
        imageMimeType: imageMimeType,
        lat: continueLat,
        lng: continueLng,
      )) {
        acc.apply(event);
        if (!mounted) return;
        setState(() {
          _messages[assistantIndex] = ChatMessage(
            text: acc.replyText,
            isUser: false,
            streaming: true,
            cards: acc.cards,
            workflow: acc.workflow,
          );
        });
        _scrollToBottom();
      }
      stopwatch.stop();
      if (!mounted) return;
      setState(() {
        _messages[assistantIndex] = ChatMessage(
          text: acc.replyText,
          isUser: false,
          thinkingSeconds: stopwatch.elapsedMilliseconds / 1000,
          cards: acc.cards,
          workflow: acc.workflow,
        );
      });
    } catch (e) {
      stopwatch.stop();
      if (mounted) {
        setState(() {
          _messages[assistantIndex] = ChatMessage(
            text: '续跑失败：$e',
            isUser: false,
            thinkingSeconds: stopwatch.elapsedMilliseconds / 1000,
          );
        });
      }
    } finally {
      _stopThinkingTimer();
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        imageQuality: 85,
      );
      if (file != null && mounted) {
        setState(() => _pendingImage = file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('选图失败：$e')));
      }
    }
  }

  void _openConversations() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const AiConversationsPage()),
    );
  }

  void _openCard(ChatActionCard card) {
    if (card.type == 'recipe') {
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => RecipeDetailPage(recipeId: card.id),
        ),
      );
    } else if (card.type == 'restaurant') {
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => RestaurantDetailPage(restaurantId: card.id),
        ),
      );
    } else if (card.type == 'vote_room' && card.roomCode != null) {
      Navigator.pushNamed(context, AppRoutes.vote, arguments: card.roomCode);
    }
  }

  Future<void> _markWant(ChatActionCard card) async {
    if (card.type != 'restaurant') return;
    try {
      await _nearbyRepo.markWant(card.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('已标记「${card.name}」为想去')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _favoriteItem(ChatActionCard card) async {
    try {
      if (card.type == 'recipe') {
        await _favRepo.addRecipe(
          title: card.name,
          recipeId: card.id,
          category: card.subtitle,
        );
      } else if (card.type == 'restaurant') {
        await _favRepo.addRestaurant(
          restaurantId: card.id,
          title: card.name,
          category: card.subtitle,
        );
      } else {
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('已收藏「${card.name}」')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  void _continueAsk(ChatActionCard card) {
    _inputCtrl.text = '请详细介绍一下「${card.name}」';
    _inputCtrl.selection = TextSelection.collapsed(
      offset: _inputCtrl.text.length,
    );
  }

  Future<void> _startVoteFromCards(List<ChatActionCard> cards) async {
    final options = cards
        .where((c) => c.type == 'restaurant')
        .map((c) => c.name)
        .toSet()
        .toList();
    if (options.length < 2) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('至少需要 2 家餐厅才能发起投票')));
      }
      return;
    }
    try {
      final room = await _roomRepo.createRoom(
        topic: 'AI 推荐 · 今晚吃什么',
        initialOptions: options,
      );
      if (!mounted) return;
      Navigator.pushNamed(context, AppRoutes.vote, arguments: room.code);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  void _scrollToBottom() {
    void jump() {
      if (!_scrollCtrl.hasClients) return;
      final target = _scrollCtrl.position.maxScrollExtent;
      if ((_scrollCtrl.position.pixels - target).abs() < 1) return;
      _scrollCtrl.jumpTo(target);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      jump();
      WidgetsBinding.instance.addPostFrameCallback((_) => jump());
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 美食助手'),
        actions: [
          IconButton(
            onPressed: _openMemory,
            icon: const Icon(Icons.psychology_outlined),
            tooltip: 'AI 记忆',
          ),
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
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              itemCount: _messages.length + (_loadingOlder ? 1 : 0),
              itemBuilder: (context, index) {
                if (_loadingOlder && index == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                final messageIndex = _loadingOlder ? index - 1 : index;
                if (messageIndex < 0 || messageIndex >= _messages.length) {
                  return const SizedBox.shrink();
                }
                final msg = _messages[messageIndex];
                return _Bubble(
                  message: msg,
                  thinkingElapsed: msg.streaming &&
                          msg.text.isEmpty &&
                          msg.workflow == null
                      ? _thinkingElapsed
                      : null,
                  onFavorite: !msg.isUser && !msg.streaming
                      ? () => _favoriteReply(messageIndex)
                      : null,
                  onOpenCard: _openCard,
                  onMarkWant: _markWant,
                  onFavoriteItem: _favoriteItem,
                  onContinueAsk: _continueAsk,
                  onStartVote: !msg.isUser && !msg.streaming
                      ? () => _startVoteFromCards(msg.cards)
                      : null,
                  onContinueWorkflow:
                      !msg.isUser &&
                          !msg.streaming &&
                          !_sending &&
                          msg.workflow?.status == 'waiting'
                      ? () => _continueWorkflow(msg)
                      : null,
                  onSkipPhoto:
                      !msg.isUser &&
                          !msg.streaming &&
                          !_sending &&
                          msg.workflow?.status == 'waiting' &&
                          msg.workflow!.steps.any(
                            (step) =>
                                step.id == 'vision' && step.status == 'waiting',
                          )
                      ? () => _continueWorkflow(msg, skipPhoto: true)
                      : null,
                );
              },
            ),
          ),
          if (_sending)
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          if (!_sending && _prefLoaded)
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _quickPrompts.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final prompt = _quickPrompts[index];
                  return ActionChip(
                    label: Text(prompt),
                    onPressed: () => _send(prompt),
                  );
                },
              ),
            ),
          const SizedBox(height: 6),
          if (_pendingImage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_pendingImage!.path),
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '已选图片，可补充说明或直接发送',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _pendingImage = null),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _sending ? null : _pickImage,
                    icon: const Icon(Icons.photo_camera_outlined),
                    tooltip: '发送图片识菜',
                  ),
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
                        fillColor: colors.inputFill,
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
  const _Bubble({
    required this.message,
    this.onFavorite,
    this.thinkingElapsed,
    this.onOpenCard,
    this.onMarkWant,
    this.onFavoriteItem,
    this.onContinueAsk,
    this.onStartVote,
    this.onContinueWorkflow,
    this.onSkipPhoto,
  });

  final ChatMessage message;
  final VoidCallback? onFavorite;
  final double? thinkingElapsed;
  final void Function(ChatActionCard card)? onOpenCard;
  final Future<void> Function(ChatActionCard card)? onMarkWant;
  final Future<void> Function(ChatActionCard card)? onFavoriteItem;
  final void Function(ChatActionCard card)? onContinueAsk;
  final VoidCallback? onStartVote;
  final VoidCallback? onContinueWorkflow;
  final VoidCallback? onSkipPhoto;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isUser = message.isUser;
    if (!isUser &&
        message.streaming &&
        message.text.isEmpty &&
        message.workflow == null) {
      return _ThinkingBubble(elapsed: thinkingElapsed ?? 0);
    }
    final maxWidth = MediaQuery.sizeOf(context).width * (isUser ? 0.78 : 0.92);
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: BoxDecoration(
          color: isUser ? colors.accent : colors.cardBackground,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isUser) ...[
              if (message.imagePath != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(message.imagePath!),
                      width: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (message.text.isNotEmpty)
                Text(
                  message.text,
                  style: TextStyle(color: colors.onAccent, height: 1.45),
                ),
            ] else ...[
              if (message.workflow != null) ...[
                WorkflowCard(
                  snapshot: message.workflow!,
                  onContinue: onContinueWorkflow,
                  onSkip: onSkipPhoto,
                ),
                if (message.text.isNotEmpty) const SizedBox(height: 8),
              ],
              if (message.text.isNotEmpty || message.workflow == null)
                MarkdownBody(
                  data: message.text.isEmpty ? '…' : message.text,
                  selectable: true,
                  styleSheet: _assistantMarkdownStyle(colors),
                ),
            ],
            if (!isUser && message.cards.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...message.cards.map(
                (card) => _CardBlock(
                  card: card,
                  onOpenCard: onOpenCard,
                  onMarkWant: onMarkWant,
                  onFavoriteItem: onFavoriteItem,
                  onContinueAsk: onContinueAsk,
                ),
              ),
              if (onStartVote != null &&
                  message.cards.where((c) => c.type == 'restaurant').length >=
                      2)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: OutlinedButton.icon(
                    onPressed: onStartVote,
                    icon: const Icon(Icons.how_to_vote_outlined, size: 16),
                    label: const Text('用这些店发起投票'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: colors.infoText,
                    ),
                  ),
                ),
            ],
            if (!isUser && !message.streaming) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  if (message.thinkingSeconds != null)
                    Text(
                      '思考 ${_formatThinking(message.thinkingSeconds!)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textSecondary,
                      ),
                    ),
                  const Spacer(),
                  if (onFavorite != null)
                    InkWell(
                      onTap: message.favorited ? null : onFavorite,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          message.favorited
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 18,
                          color: message.favorited
                              ? colors.accent
                              : colors.textSecondary,
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

  static MarkdownStyleSheet _assistantMarkdownStyle(AppSemanticColors colors) =>
      MarkdownStyleSheet(
        p: TextStyle(color: colors.textPrimary, height: 1.5, fontSize: 15),
        strong: TextStyle(
          fontWeight: FontWeight.w800,
          color: colors.textPrimary,
        ),
        em: TextStyle(fontStyle: FontStyle.italic, color: colors.textPrimary),
        h1: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: colors.textPrimary,
        ),
        h2: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: colors.textPrimary,
        ),
        h3: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
        listBullet: TextStyle(color: colors.textPrimary, fontSize: 15),
        listIndent: 22,
        blockSpacing: 10,
        horizontalRuleDecoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.cardBorder)),
        ),
      );

  static String _formatThinking(double seconds) =>
      '${seconds.toStringAsFixed(2)} 秒';
}

class _CardBlock extends StatelessWidget {
  const _CardBlock({
    required this.card,
    this.onOpenCard,
    this.onMarkWant,
    this.onFavoriteItem,
    this.onContinueAsk,
  });

  final ChatActionCard card;
  final void Function(ChatActionCard card)? onOpenCard;
  final Future<void> Function(ChatActionCard card)? onMarkWant;
  final Future<void> Function(ChatActionCard card)? onFavoriteItem;
  final void Function(ChatActionCard card)? onContinueAsk;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final icon = switch (card.type) {
      'recipe' => Icons.restaurant_menu_outlined,
      'vote_room' => Icons.how_to_vote_outlined,
      _ => Icons.storefront_outlined,
    };
    final label = card.type == 'vote_room' && card.roomCode != null
        ? '${card.name} · ${card.roomCode}'
        : card.name;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ActionChip(
            avatar: Icon(icon, size: 16, color: colors.infoText),
            label: Text(label),
            onPressed: onOpenCard != null ? () => onOpenCard!(card) : null,
          ),
          if (card.type != 'vote_room')
            Wrap(
              spacing: 4,
              children: [
                if (card.type == 'restaurant' && onMarkWant != null)
                  _MiniAction(label: '想去', onTap: () => onMarkWant!(card)),
                if ((card.type == 'recipe' || card.type == 'restaurant') &&
                    onFavoriteItem != null)
                  _MiniAction(label: '收藏', onTap: () => onFavoriteItem!(card)),
                if (onContinueAsk != null)
                  _MiniAction(label: '追问', onTap: () => onContinueAsk!(card)),
              ],
            ),
        ],
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: colors.textSecondary,
        textStyle: const TextStyle(fontSize: 12),
      ),
      child: Text(label),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble({required this.elapsed});

  final double elapsed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
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
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
