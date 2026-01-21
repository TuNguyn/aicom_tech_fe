import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/socket/socket_service.dart';

class SocketState {
  final bool isConnected;
  final AsyncValue<void> connectionStatus;
  final Map<String, dynamic>? lastEventData;
  final DateTime? lastEventTime;
  final String? lastEventType;

  SocketState({
    this.isConnected = false,
    this.connectionStatus = const AsyncValue.data(null),
    this.lastEventData,
    this.lastEventTime,
    this.lastEventType,
  });

  SocketState copyWith({
    bool? isConnected,
    AsyncValue<void>? connectionStatus,
    Map<String, dynamic>? lastEventData,
    DateTime? lastEventTime,
    String? lastEventType,
  }) {
    return SocketState(
      isConnected: isConnected ?? this.isConnected,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      lastEventData: lastEventData ?? this.lastEventData,
      lastEventTime: lastEventTime ?? this.lastEventTime,
      lastEventType: lastEventType ?? this.lastEventType,
    );
  }
}

class SocketNotifier extends StateNotifier<SocketState> {
  final SocketService _socketService;
  StreamSubscription<bool>? _connectionSubscription;
  final List<StreamSubscription> _eventSubscriptions = [];

  SocketNotifier(this._socketService) : super(SocketState()) {
    _initializeConnectionListener();
  }

  void _initializeConnectionListener() {
    _connectionSubscription = _socketService.connectionState.listen((isConnected) {
      state = state.copyWith(isConnected: isConnected);

      if (isConnected) {
        _subscribeToEvents();
      }
    });
  }

  void _subscribeToEvents() {
    // Clear previous subscriptions
    for (var subscription in _eventSubscriptions) {
      subscription.cancel();
    }
    _eventSubscriptions.clear();

    // Subscribe to EMPLOYEE:SYNC
    final employeeSyncSub = _socketService.on('EMPLOYEE:SYNC').listen((data) {
      _handleEmployeeSync(data);
    });
    _eventSubscriptions.add(employeeSyncSub);

    // Subscribe to CLOCK_IN:SYNC
    final clockInSyncSub = _socketService.on('CLOCK_IN:SYNC').listen((data) {
      _handleClockInSync(data);
    });
    _eventSubscriptions.add(clockInSyncSub);

    // Subscribe to TICKET:SYNC
    final ticketSyncSub = _socketService.on('TICKET:SYNC').listen((data) {
      _handleTicketSync(data);
    });
    _eventSubscriptions.add(ticketSyncSub);
  }

  void _handleEmployeeSync(dynamic data) {
    // Phase 1: Log only
    print('[Socket] EMPLOYEE:SYNC: $data');

    state = state.copyWith(
      lastEventData: data is Map<String, dynamic> ? data : {'raw': data},
      lastEventTime: DateTime.now(),
      lastEventType: 'EMPLOYEE:SYNC',
    );

    // Phase 2: Trigger refresh
    // ref.read(employeeNotifierProvider.notifier).refreshEmployees();
  }

  void _handleClockInSync(dynamic data) {
    // Phase 1: Log only
    print('[Socket] CLOCK_IN:SYNC: $data');

    state = state.copyWith(
      lastEventData: data is Map<String, dynamic> ? data : {'raw': data},
      lastEventTime: DateTime.now(),
      lastEventType: 'CLOCK_IN:SYNC',
    );

    // Phase 2: Trigger refresh
    // ref.read(clockInNotifierProvider.notifier).refreshClockInStatus();
  }

  void _handleTicketSync(dynamic data) {
    // Phase 1: Log only
    print('[Socket] TICKET:SYNC: $data');

    state = state.copyWith(
      lastEventData: data is Map<String, dynamic> ? data : {'raw': data},
      lastEventTime: DateTime.now(),
      lastEventType: 'TICKET:SYNC',
    );

    // Phase 2: Trigger refresh
    // ref.read(appointmentsNotifierProvider.notifier).refreshAppointments();
  }

  void connect(String authToken) {
    state = state.copyWith(connectionStatus: const AsyncValue.loading());

    try {
      _socketService.connect(authToken);
      state = state.copyWith(connectionStatus: const AsyncValue.data(null));
    } catch (e, stack) {
      state = state.copyWith(
        connectionStatus: AsyncValue.error(e, stack),
      );
      print('[Socket] Connection error: $e');
    }
  }

  void disconnect() {
    _socketService.disconnect();
    state = state.copyWith(
      isConnected: false,
      lastEventData: null,
      lastEventTime: null,
      lastEventType: null,
    );
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    for (var subscription in _eventSubscriptions) {
      subscription.cancel();
    }
    _eventSubscriptions.clear();
    _socketService.dispose();
    super.dispose();
  }
}
