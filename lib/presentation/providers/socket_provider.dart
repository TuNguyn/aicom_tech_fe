// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/socket/socket_service.dart';

class SocketState {
  final bool isConnected;
  final AsyncValue<void> connectionStatus;
  final Map<String, dynamic>? lastEventData;
  final DateTime? lastEventTime;
  final String? lastEventType;
  final String currentUserName;
  final bool hasNewAssignedTicket; // Flag to trigger refresh

  SocketState({
    this.isConnected = false,
    this.connectionStatus = const AsyncValue.data(null),
    this.lastEventData,
    this.lastEventTime,
    this.lastEventType,
    this.currentUserName = '',
    this.hasNewAssignedTicket = false,
  });

  SocketState copyWith({
    bool? isConnected,
    AsyncValue<void>? connectionStatus,
    Map<String, dynamic>? lastEventData,
    DateTime? lastEventTime,
    String? lastEventType,
    String? currentUserName,
    bool? hasNewAssignedTicket,
  }) {
    return SocketState(
      isConnected: isConnected ?? this.isConnected,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      lastEventData: lastEventData ?? this.lastEventData,
      lastEventTime: lastEventTime ?? this.lastEventTime,
      lastEventType: lastEventType ?? this.lastEventType,
      currentUserName: currentUserName ?? this.currentUserName,
      hasNewAssignedTicket: hasNewAssignedTicket ?? this.hasNewAssignedTicket,
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
    print('[Socket] TICKET:SYNC received');
    print('[Socket] Event data type: ${data.runtimeType}');
    print('[Socket] Full data: $data');

    // Get current user's full name from state
    final currentUserName = state.currentUserName;
    print('[Socket] Current user: "$currentUserName"');

    if (currentUserName.isEmpty) {
      print('[Socket] ⚠️ Warning: currentUserName is empty!');
      return;
    }

    // Parse the event data
    if (data is Map<String, dynamic>) {
      print('[Socket] ✓ Data is Map');
      final eventData = data['data'];
      print('[Socket] eventData: $eventData');

      if (eventData != null && eventData is Map<String, dynamic>) {
        print('[Socket] ✓ eventData is Map');
        final ticketLines = eventData['ticketLines'];
        print('[Socket] ticketLines count: ${ticketLines?.length ?? 0}');

        if (ticketLines != null && ticketLines is List) {
          print('[Socket] ✓ ticketLines is List with ${ticketLines.length} items');

          // Debug each line
          for (var i = 0; i < ticketLines.length; i++) {
            final line = ticketLines[i];
            if (line is Map<String, dynamic>) {
              final employeeName = line['employeeName'];
              print('[Socket]   Line $i: employeeName = "$employeeName"');
              print('[Socket]   Line $i: Match = ${employeeName == currentUserName}');
            }
          }

          // Check if any ticket line matches current employee's name
          final hasMatchingLine = ticketLines.any((line) {
            if (line is Map<String, dynamic>) {
              final employeeName = line['employeeName'];
              return employeeName == currentUserName;
            }
            return false;
          });

          print('[Socket] ========================================');
          print('[Socket] Has ticket for "$currentUserName": $hasMatchingLine');
          print('[Socket] ========================================');

          if (hasMatchingLine) {
            // Set flag to trigger API refresh
            state = state.copyWith(
              hasNewAssignedTicket: true,
              lastEventData: data,
              lastEventTime: DateTime.now(),
              lastEventType: 'TICKET:SYNC',
            );
            print('[Socket] ✅ Flag set: hasNewAssignedTicket = true');
            print('[Socket] Current state.hasNewAssignedTicket = ${state.hasNewAssignedTicket}');
          } else {
            // Update event data without triggering refresh
            state = state.copyWith(
              lastEventData: data,
              lastEventTime: DateTime.now(),
              lastEventType: 'TICKET:SYNC',
            );
            print('[Socket] ⚠️ No matching line, flag NOT set');
          }
        } else {
          print('[Socket] ❌ ticketLines is null or not a List');
        }
      } else {
        print('[Socket] ❌ eventData is null or not a Map');
      }
    } else {
      print('[Socket] ❌ data is not a Map');
    }
  }

  /// Clear the new assigned ticket flag
  void clearAssignedTicketFlag() {
    state = state.copyWith(hasNewAssignedTicket: false);
  }

  void connect(String authToken, String userFullName) {
    state = state.copyWith(
      connectionStatus: const AsyncValue.loading(),
      currentUserName: userFullName,
    );

    try {
      _socketService.connect(authToken);
      state = state.copyWith(connectionStatus: const AsyncValue.data(null));
      print('[Socket] Connected with user: $userFullName');
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
      currentUserName: '',
      hasNewAssignedTicket: false,
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
