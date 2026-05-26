import 'dart:async';
import 'dart:convert';

import 'package:soulfood_front/core/config/app_config.dart';
import 'package:soulfood_front/features/room/room_models.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef RoomUpdateCallback = void Function(RoomDetail room);
typedef RoomWsStateCallback = void Function(bool connected);

class RoomWebSocketClient {
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  bool _disposed = false;
  bool _connected = false;

  bool get isConnected => _connected;

  void connect({
    required String roomCode,
    required String token,
    required RoomUpdateCallback onUpdate,
    RoomWsStateCallback? onConnectionChanged,
  }) {
    _disposed = false;
    _connectInternal(
      roomCode: roomCode,
      token: token,
      onUpdate: onUpdate,
      onConnectionChanged: onConnectionChanged,
    );
  }

  void _connectInternal({
    required String roomCode,
    required String token,
    required RoomUpdateCallback onUpdate,
    RoomWsStateCallback? onConnectionChanged,
  }) {
    _subscription?.cancel();
    _channel?.sink.close();

    final uri = Uri.parse(
      '${AppConfig.wsBaseUrl}/ws/rooms/${roomCode.toUpperCase()}?token=${Uri.encodeComponent(token)}',
    );

    try {
      _channel = WebSocketChannel.connect(uri);
    } catch (_) {
      _setConnected(false, onConnectionChanged);
      _scheduleReconnect(
        roomCode: roomCode,
        token: token,
        onUpdate: onUpdate,
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
          if (json['type'] == 'room_update') {
            final data = json['data'];
            if (data is Map<String, dynamic>) {
              onUpdate(RoomDetail.fromJson(data));
            }
          }
        } catch (_) {
          // ignore malformed frames
        }
      },
      onError: (_) {
        _setConnected(false, onConnectionChanged);
        _scheduleReconnect(
          roomCode: roomCode,
          token: token,
          onUpdate: onUpdate,
          onConnectionChanged: onConnectionChanged,
        );
      },
      onDone: () {
        _setConnected(false, onConnectionChanged);
        _scheduleReconnect(
          roomCode: roomCode,
          token: token,
          onUpdate: onUpdate,
          onConnectionChanged: onConnectionChanged,
        );
      },
      cancelOnError: true,
    );
  }

  void _scheduleReconnect({
    required String roomCode,
    required String token,
    required RoomUpdateCallback onUpdate,
    RoomWsStateCallback? onConnectionChanged,
  }) {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (_disposed) return;
      _connectInternal(
        roomCode: roomCode,
        token: token,
        onUpdate: onUpdate,
        onConnectionChanged: onConnectionChanged,
      );
    });
  }

  void _setConnected(bool value, RoomWsStateCallback? onConnectionChanged) {
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
