import 'dart:async';
import 'dart:convert';

import 'package:soulfood_front/core/config/app_config.dart';
import 'package:soulfood_front/features/friend_chat/friend_chat_models.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef FriendChatMessageCallback = void Function(FriendChatMessage message);
typedef FriendChatWsStateCallback = void Function(bool connected);

class FriendChatWebSocketClient {
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  bool _disposed = false;
  bool _connected = false;

  bool get isConnected => _connected;

  void connect({
    required int conversationId,
    required String token,
    required FriendChatMessageCallback onMessage,
    FriendChatWsStateCallback? onConnectionChanged,
  }) {
    _disposed = false;
    _connectInternal(
      conversationId: conversationId,
      token: token,
      onMessage: onMessage,
      onConnectionChanged: onConnectionChanged,
    );
  }

  void _connectInternal({
    required int conversationId,
    required String token,
    required FriendChatMessageCallback onMessage,
    FriendChatWsStateCallback? onConnectionChanged,
  }) {
    _subscription?.cancel();
    _channel?.sink.close();

    final uri = Uri.parse(
      '${AppConfig.wsBaseUrl}/ws/friend-chat/$conversationId?token=${Uri.encodeComponent(token)}',
    );

    try {
      _channel = WebSocketChannel.connect(uri);
    } catch (_) {
      _setConnected(false, onConnectionChanged);
      _scheduleReconnect(
        conversationId: conversationId,
        token: token,
        onMessage: onMessage,
        onConnectionChanged: onConnectionChanged,
      );
      return;
    }

    _setConnected(true, onConnectionChanged);
    _subscription = _channel!.stream.listen(
      (event) {
        if (event is! String) return;
        try {
          final json = jsonDecode(event) as Map<String, dynamic>;
          if (json['type'] == 'message') {
            final data = json['data'];
            if (data is Map<String, dynamic>) {
              onMessage(FriendChatMessage.fromJson(data));
            }
          }
        } catch (_) {
          // ignore malformed frames
        }
      },
      onError: (_) {
        _setConnected(false, onConnectionChanged);
        _scheduleReconnect(
          conversationId: conversationId,
          token: token,
          onMessage: onMessage,
          onConnectionChanged: onConnectionChanged,
        );
      },
      onDone: () {
        _setConnected(false, onConnectionChanged);
        _scheduleReconnect(
          conversationId: conversationId,
          token: token,
          onMessage: onMessage,
          onConnectionChanged: onConnectionChanged,
        );
      },
      cancelOnError: true,
    );
  }

  void _scheduleReconnect({
    required int conversationId,
    required String token,
    required FriendChatMessageCallback onMessage,
    FriendChatWsStateCallback? onConnectionChanged,
  }) {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (_disposed) return;
      _connectInternal(
        conversationId: conversationId,
        token: token,
        onMessage: onMessage,
        onConnectionChanged: onConnectionChanged,
      );
    });
  }

  void _setConnected(bool value, FriendChatWsStateCallback? onConnectionChanged) {
    _connected = value;
    onConnectionChanged?.call(value);
  }

  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    _connected = false;
  }
}
