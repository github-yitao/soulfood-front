import 'package:soulfood_front/core/api/api_client.dart';
import 'package:soulfood_front/core/app_bootstrap.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeItem {
  RecipeItem({required this.name, required this.score, this.reason = ''});

  final String name;
  final String score;
  final String reason;

  factory RecipeItem.fromJson(Map<String, dynamic> json) {
    return RecipeItem(
      name: json['name'] as String? ?? '',
      score: (json['score'] as num?)?.toString() ?? '4.5',
      reason: json['reason'] as String? ?? '',
    );
  }
}

class RandomPickResult {
  RandomPickResult({required this.name, required this.reason});

  final String name;
  final String reason;

  factory RandomPickResult.fromJson(Map<String, dynamic> json) {
    return RandomPickResult(
      name: json['name'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }
}

class ChatActionCard {
  ChatActionCard({
    required this.type,
    required this.id,
    required this.name,
    this.subtitle,
  });

  final String type;
  final int id;
  final String name;
  final String? subtitle;

  /// vote_room 类型的房间号存在 subtitle
  String? get roomCode => type == 'vote_room' ? subtitle : null;

  factory ChatActionCard.fromJson(Map<String, dynamic> json) {
    return ChatActionCard(
      type: json['type'] as String? ?? '',
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
    );
  }
}

class ChatReply {
  ChatReply({
    required this.conversationId,
    required this.reply,
    this.cards = const [],
  });

  final String conversationId;
  final String reply;
  final List<ChatActionCard> cards;

  factory ChatReply.fromJson(Map<String, dynamic> json) {
    final rawCards = json['cards'] as List<dynamic>? ?? [];
    return ChatReply(
      conversationId: json['conversationId'] as String? ?? '',
      reply: json['reply'] as String? ?? '',
      cards: rawCards
          .map((e) => ChatActionCard.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AiConversationItem {
  AiConversationItem({
    required this.id,
    required this.title,
    required this.preview,
    this.sceneTag,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String preview;
  final String? sceneTag;
  final DateTime? updatedAt;

  factory AiConversationItem.fromJson(Map<String, dynamic> json) {
    return AiConversationItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '新对话',
      preview: json['preview'] as String? ?? '',
      sceneTag: json['sceneTag'] as String?,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }
}

class AiUserMemoryItem {
  AiUserMemoryItem({
    required this.id,
    required this.memoryType,
    required this.content,
    required this.source,
    this.updatedAt,
  });

  final int id;
  final String memoryType;
  final String content;
  final String source;
  final DateTime? updatedAt;

  factory AiUserMemoryItem.fromJson(Map<String, dynamic> json) {
    return AiUserMemoryItem(
      id: (json['id'] as num).toInt(),
      memoryType: json['memoryType'] as String? ?? 'long_term',
      content: json['content'] as String? ?? '',
      source: json['source'] as String? ?? 'user',
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }

  String get typeLabel => memoryType == 'episodic' ? '近期经历' : '长期记忆';
}

class ChatHistoryMessage {
  ChatHistoryMessage({
    required this.role,
    required this.content,
    this.cards = const [],
  });

  final String role;
  final String content;
  final List<ChatActionCard> cards;

  factory ChatHistoryMessage.fromJson(Map<String, dynamic> json) {
    final rawCards = json['cards'] as List<dynamic>? ?? [];
    return ChatHistoryMessage(
      role: json['role'] as String? ?? 'assistant',
      content: json['content'] as String? ?? '',
      cards: rawCards
          .map((e) => ChatActionCard.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AgentRepository {
  AgentRepository() : _api = AppServices.I.api;

  final ApiClient _api;
  static const _conversationKey = 'ai_conversation_id';

  Future<String?> loadConversationId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_conversationKey);
  }

  Future<void> saveConversationId(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null || id.isEmpty) {
      await prefs.remove(_conversationKey);
    } else {
      await prefs.setString(_conversationKey, id);
    }
  }

  Future<ChatReply> chat({
    required String message,
    String? conversationId,
    double? lat,
    double? lng,
  }) async {
    final data = await _api.postData<Map<String, dynamic>>(
      '/ai/chat',
      data: {
        'message': message,
        if (conversationId != null && conversationId.isNotEmpty)
          'conversationId': conversationId,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
      },
      parser: (json) => json as Map<String, dynamic>,
    );
    final reply = ChatReply.fromJson(data);
    if (reply.conversationId.isNotEmpty) {
      await saveConversationId(reply.conversationId);
    }
    return reply;
  }

  Stream<Map<String, dynamic>> chatStream({
    required String message,
    String? conversationId,
    double? lat,
    double? lng,
    String? imageBase64,
    String? imageMimeType,
  }) {
    return _api.postNdjsonStream(
      '/ai/chat/stream',
      data: {
        'message': message,
        if (conversationId != null && conversationId.isNotEmpty)
          'conversationId': conversationId,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (imageBase64 != null && imageBase64.isNotEmpty) 'imageBase64': imageBase64,
        if (imageMimeType != null && imageMimeType.isNotEmpty) 'imageMimeType': imageMimeType,
      },
    );
  }

  Future<void> clearConversation(String conversationId) async {
    await _api.deleteVoid('/ai/chat/$conversationId');
    await saveConversationId(null);
  }

  Future<List<AiConversationItem>> listConversations({
    String? keyword,
    String? sceneTag,
  }) async {
    return _api.getData<List<AiConversationItem>>(
      '/ai/conversations',
      query: {
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
        if (sceneTag != null && sceneTag.isNotEmpty) 'sceneTag': sceneTag,
      },
      parser: (json) => (json as List<dynamic>)
          .map((e) => AiConversationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<void> updateConversation(
    String conversationId, {
    String? title,
    String? sceneTag,
  }) async {
    await _api.patchVoid(
      '/ai/conversations/$conversationId',
      data: {
        if (title != null && title.isNotEmpty) 'title': title,
        if (sceneTag != null) 'sceneTag': sceneTag,
      },
    );
  }

  Future<List<ChatHistoryMessage>> loadHistory(String conversationId) async {
    return _api.getData<List<ChatHistoryMessage>>(
      '/ai/chat/$conversationId/history',
      parser: (json) => (json as List<dynamic>)
          .map((e) => ChatHistoryMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<List<RecipeItem>> recommendRecipes({
    String preference = '清淡、家常菜',
    String? voteWinner,
    int? participants,
  }) async {
    try {
      final data = await _api.postData<Map<String, dynamic>>(
        '/ai/recommend/recipes',
        data: {
          'preference': preference,
          if (voteWinner != null && voteWinner.isNotEmpty) 'voteWinner': voteWinner,
          if (participants != null) 'participants': participants,
        },
        parser: (json) => json as Map<String, dynamic>,
      );
      final items = data['items'] as List<dynamic>? ?? [];
      if (items.isNotEmpty) {
        return items
            .map((e) => RecipeItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      final raw = data['rawReply'] as String? ?? '';
      final parsed = _parseRecipesFromText(raw);
      if (parsed.isNotEmpty) return parsed;
    } catch (_) {
      // fallback below
    }
    return _fallbackRecipes(voteWinner);
  }

  List<RecipeItem> _fallbackRecipes(String? voteWinner) {
    if (voteWinner != null && voteWinner.contains('火锅')) {
      return [
        RecipeItem(name: '毛肚', score: '4.8', reason: '火锅经典（离线推荐）'),
        RecipeItem(name: '肥牛卷', score: '4.7', reason: '搭配火锅很合适'),
        RecipeItem(name: '娃娃菜', score: '4.6', reason: '解腻必备'),
      ];
    }
    return [
      RecipeItem(name: '番茄炒蛋', score: '4.8', reason: '清淡下饭（离线推荐）'),
      RecipeItem(name: '土豆丝炒肉', score: '4.6', reason: '家常菜'),
      RecipeItem(name: '青菜鸡蛋面', score: '4.7', reason: '快手暖胃'),
    ];
  }

  Future<List<String>> suggestOptions({
    required String topic,
    List<String> existingOptions = const [],
  }) async {
    final data = await _api.postData<Map<String, dynamic>>(
      '/ai/suggest-options',
      data: {
        'topic': topic,
        'existingOptions': existingOptions,
      },
      parser: (json) => json as Map<String, dynamic>,
    );
    final options = data['options'] as List<dynamic>? ?? [];
    return options.map((e) => '$e').where((s) => s.length >= 2).take(4).toList();
  }

  Future<RandomPickResult> randomPick({
    required List<String> candidates,
    String preference = '',
  }) async {
    return _api.postData<RandomPickResult>(
      '/ai/random-pick',
      data: {
        'candidates': candidates,
        if (preference.isNotEmpty) 'preference': preference,
      },
      parser: (json) => RandomPickResult.fromJson(json as Map<String, dynamic>),
    );
  }

  List<RecipeItem> _parseRecipesFromText(String text) {
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) {
      return [
        RecipeItem(name: '番茄炒蛋', score: '4.8', reason: '演示推荐'),
        RecipeItem(name: '土豆丝炒肉', score: '4.6', reason: '演示推荐'),
      ];
    }
    return lines.take(5).map((line) {
      final scoreMatch = RegExp(r'(\d\.\d)').firstMatch(line);
      var name = line.replaceAll(RegExp(r'^[\d\.\)、\-\*•\s]+'), '').trim();
      final colon = name.contains('：') ? name.indexOf('：') : name.indexOf(':');
      var reason = '';
      if (colon > 0) {
        reason = name.substring(colon + 1).trim();
        name = name.substring(0, colon).trim();
      }
      if (name.length > 20) name = name.substring(0, 20);
      return RecipeItem(
        name: name.isEmpty ? '推荐菜' : name,
        score: scoreMatch?.group(1) ?? '4.5',
        reason: reason.isEmpty ? line : reason,
      );
    }).toList();
  }

  Future<List<AiUserMemoryItem>> listMemories({String? memoryType}) async {
    return _api.getData<List<AiUserMemoryItem>>(
      '/ai/memory',
      query: memoryType != null && memoryType.isNotEmpty ? {'memoryType': memoryType} : null,
      parser: (json) => (json as List<dynamic>)
          .map((e) => AiUserMemoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<AiUserMemoryItem> addMemory({
    required String content,
    String memoryType = 'long_term',
  }) async {
    final data = await _api.postData<Map<String, dynamic>>(
      '/ai/memory',
      data: {'content': content, 'memoryType': memoryType},
      parser: (json) => json as Map<String, dynamic>,
    );
    return AiUserMemoryItem.fromJson(data);
  }

  Future<void> deleteMemory(int id) async {
    await _api.deleteVoid('/ai/memory/$id');
  }
}
