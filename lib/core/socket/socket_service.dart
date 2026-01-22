// ignore_for_file: avoid_print

import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  final String socketUrl;
  io.Socket? _socket;

  final _connectionStateController = StreamController<bool>.broadcast();
  final _eventControllers = <String, StreamController<dynamic>>{};

  Stream<bool> get connectionState => _connectionStateController.stream;
  bool get isConnected => _socket?.connected ?? false;

  SocketService({required this.socketUrl});

  /// Connect to the socket with JWT authentication
  void connect(String authToken) {
    if (_socket?.connected ?? false) {
      print('[Socket] Already connected');
      return;
    }

    print('[Socket] Connecting to $socketUrl');
    print('[Socket] Auth header: Bearer ${authToken.substring(0, 20)}...');

    _socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({
            'Authorization': 'Bearer $authToken',
          })
          .build(),
    );

    _socket!.onConnect((_) {
      print('[Socket] Connected successfully');
      _connectionStateController.add(true);
    });

    _socket!.onDisconnect((_) {
      print('[Socket] Disconnected');
      _connectionStateController.add(false);
    });

    _socket!.onError((error) {
      print('[Socket] Error: $error');
    });

    _socket!.onConnectError((error) {
      print('[Socket] Connection error: $error');
    });

    _socket!.connect();
  }

  /// Disconnect from the socket
  void disconnect() {
    if (_socket == null) {
      print('[Socket] No active connection to disconnect');
      return;
    }

    print('[Socket] Disconnecting');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;

    // Clear event controllers so they can be re-registered on reconnect
    print('[Socket] Clearing event listeners');
    for (var controller in _eventControllers.values) {
      controller.close();
    }
    _eventControllers.clear();
  }

  /// Listen to a specific event
  Stream<dynamic> on(String eventName) {
    if (!_eventControllers.containsKey(eventName)) {
      _eventControllers[eventName] = StreamController<dynamic>.broadcast();

      _socket?.on(eventName, (data) {
        print('[Socket] Event received - $eventName: $data');
        _eventControllers[eventName]?.add(data);
      });

      print('[Socket] Listening to: $eventName');
    }

    return _eventControllers[eventName]!.stream;
  }

  /// Cleanup resources
  void dispose() {
    print('[Socket] Disposing socket service');
    disconnect();
    _connectionStateController.close();

    for (var controller in _eventControllers.values) {
      controller.close();
    }
    _eventControllers.clear();
  }
}
