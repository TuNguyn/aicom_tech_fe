// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/socket/socket_service.dart';
import '../../app_dependencies.dart';

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
  final Ref _ref;
  StreamSubscription<bool>? _connectionSubscription;
  final List<StreamSubscription> _eventSubscriptions = [];

  SocketNotifier(this._socketService, this._ref) : super(SocketState()) {
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
    print('[Socket] EMPLOYEE:SYNC received: $data');

    state = state.copyWith(
      lastEventData: data is Map<String, dynamic> ? data : {'raw': data},
      lastEventTime: DateTime.now(),
      lastEventType: 'EMPLOYEE:SYNC',
    );

    // Validate event format
    if (data is! Map<String, dynamic>) {
      print('[Socket] Invalid EMPLOYEE:SYNC event format - not a map');
      return;
    }

    // Extract employee ID from event data
    final eventData = data['data'];
    if (eventData == null || eventData is! Map<String, dynamic>) {
      print('[Socket] Invalid EMPLOYEE:SYNC event - missing or invalid data field');
      return;
    }

    final employeeId = eventData['id'];
    if (employeeId == null || employeeId is! String) {
      print('[Socket] Invalid EMPLOYEE:SYNC event - missing or invalid employee ID');
      return;
    }

    // Get current logged-in user ID
    final currentUser = _ref.read(authNotifierProvider).user;
    final currentUserId = currentUser.id;

    print('[Socket] Comparing IDs - Socket: $employeeId, Current: $currentUserId');

    // Only refresh if the event is for the current logged-in user
    if (employeeId == currentUserId) {
      print('[Socket] Employee data changed for current user, refreshing profile...');
      _ref.read(authNotifierProvider.notifier).refreshEmployeeProfile();
    } else {
      print('[Socket] Employee data change for different user, ignoring');
    }
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
    final currentUserName = state.currentUserName;

    if (currentUserName.isEmpty) return;

    // Parse the event data
    if (data is Map<String, dynamic>) {
      final eventData = data['data'];

      if (eventData != null && eventData is Map<String, dynamic>) {
        final ticketLines = eventData['ticketLines'];

        if (ticketLines != null && ticketLines is List) {
          // Check if any ticket line matches current employee's name
          final hasMatchingLine = ticketLines.any((line) {
            if (line is Map<String, dynamic>) {
              final employeeName = line['employeeName'];
              return employeeName == currentUserName;
            }
            return false;
          });

          if (hasMatchingLine) {
            print('[Socket] TICKET:SYNC - ticket assigned to $currentUserName');
            // Set flag to trigger API refresh
            state = state.copyWith(
              hasNewAssignedTicket: true,
              lastEventData: data,
              lastEventTime: DateTime.now(),
              lastEventType: 'TICKET:SYNC',
            );
          } else {
            // Update event data without triggering refresh
            state = state.copyWith(
              lastEventData: data,
              lastEventTime: DateTime.now(),
              lastEventType: 'TICKET:SYNC',
            );
          }
        }
      }
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
