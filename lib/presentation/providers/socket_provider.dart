import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/socket/socket_service.dart';
import '../../app_dependencies.dart';
import '../../data/models/appointment_line_model.dart';

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
    _connectionSubscription = _socketService.connectionState.listen((
      isConnected,
    ) {
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

    // Subscribe to APPOINTMENT:SYNC
    final appointmentSyncSub = _socketService.on('APPOINTMENT:SYNC').listen((
      data,
    ) {
      _handleAppointmentSync(data);
    });
    _eventSubscriptions.add(appointmentSyncSub);
  }

  void _handleEmployeeSync(dynamic data) {
    if (kDebugMode) print('[Socket] EMPLOYEE:SYNC received: $data');

    state = state.copyWith(
      lastEventData: data is Map<String, dynamic> ? data : {'raw': data},
      lastEventTime: DateTime.now(),
      lastEventType: 'EMPLOYEE:SYNC',
    );

    // Validate event format
    if (data is! Map<String, dynamic>) {
      if (kDebugMode) {
        print('[Socket] Invalid EMPLOYEE:SYNC event format - not a map');
      }
      return;
    }

    // Extract employee ID from event data
    final eventData = data['data'];
    if (eventData == null || eventData is! Map<String, dynamic>) {
      if (kDebugMode) {
        print(
          '[Socket] Invalid EMPLOYEE:SYNC event - missing or invalid data field',
        );
      }
      return;
    }

    final employeeId = eventData['id'];
    if (employeeId == null || employeeId is! String) {
      if (kDebugMode) {
        print(
          '[Socket] Invalid EMPLOYEE:SYNC event - missing or invalid employee ID',
        );
      }
      return;
    }

    // Get current logged-in user ID
    final currentUser = _ref.read(authNotifierProvider).user;
    final currentUserId = currentUser.id;

    if (kDebugMode) {
      print(
        '[Socket] Comparing IDs - Socket: $employeeId, Current: $currentUserId',
      );
    }

    // Only refresh if the event is for the current logged-in user
    if (employeeId == currentUserId) {
      if (kDebugMode) {
        print(
          '[Socket] Employee data changed for current user, refreshing profile...',
        );
      }
      _ref.read(authNotifierProvider.notifier).refreshEmployeeProfile();
    } else {
      if (kDebugMode) {
        print('[Socket] Employee data change for different user, ignoring');
      }
    }
  }

  void _handleClockInSync(dynamic data) {
    if (kDebugMode) print('[Socket] CLOCK_IN:SYNC: $data');

    state = state.copyWith(
      lastEventData: data is Map<String, dynamic> ? data : {'raw': data},
      lastEventTime: DateTime.now(),
      lastEventType: 'CLOCK_IN:SYNC',
    );
  }

  /// Generic handler for sync events with lines/items that checks employee assignment
  void _handleSyncEventWithLines({
    required dynamic data,
    required String eventType,
    required String linesKey,
    required VoidCallback onMatchFound,
  }) {
    // 1. Log & Update State
    if (kDebugMode) print('[Socket] $eventType received: $data');
    state = state.copyWith(
      lastEventData: data is Map<String, dynamic> ? data : {'raw': data},
      lastEventTime: DateTime.now(),
      lastEventType: eventType,
    );

    // 2. Validate event format
    if (data is! Map<String, dynamic>) {
      if (kDebugMode) {
        print('[Socket] Invalid $eventType event format - not a map');
      }
      return;
    }

    // 3. Extract data field
    final eventData = data['data'];
    if (eventData == null || eventData is! Map<String, dynamic>) {
      if (kDebugMode) {
        print(
          '[Socket] Invalid $eventType event - missing or invalid data field',
        );
      }
      return;
    }

    // 4. Extract lines array
    final lines = eventData[linesKey];
    if (lines == null || lines is! List) {
      if (kDebugMode) {
        print(
          '[Socket] Invalid $eventType event - missing or invalid $linesKey field',
        );
      }
      return;
    }

    // 5. Get current user ID
    final currentUser = _ref.read(authNotifierProvider).user;
    final currentUserId = currentUser.id;

    // 6. Check each line for matching employee ID
    bool foundMatch = false;
    for (var line in lines) {
      if (line is Map<String, dynamic>) {
        final employee = line['employee'];
        if (employee is Map<String, dynamic>) {
          final employeeId = employee['id'];
          if (employeeId is String) {
            if (kDebugMode) {
              print(
                '[Socket] Comparing IDs - Line employee: $employeeId, Current: $currentUserId',
              );
            }
            if (employeeId == currentUserId) {
              foundMatch = true;
              break;
            }
          }
        }
      }
    }

    // 7. Trigger callback if match found
    if (foundMatch) {
      if (kDebugMode) {
        print(
          '[Socket] $eventType assigned to current user, triggering action...',
        );
      }
      onMatchFound();
    } else {
      if (kDebugMode) {
        print('[Socket] $eventType for different employee, ignoring');
      }
    }
  }

  void _handleTicketSync(dynamic data) {
    _handleSyncEventWithLines(
      data: data,
      eventType: 'TICKET:SYNC',
      linesKey: 'ticketLines',
      onMatchFound: () {
        state = state.copyWith(hasNewAssignedTicket: true);
      },
    );
  }

  void _updateStateMetrics(dynamic data, String eventType) {
    if (kDebugMode) print('[Socket] $eventType received');
    state = state.copyWith(
      lastEventData: data is Map<String, dynamic> ? data : {'raw': data},
      lastEventTime: DateTime.now(),
      lastEventType: eventType,
    );
  }

  Map<String, dynamic>? _parseData(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    return null;
  }

  void _handleAppointmentSync(dynamic data) {
    _updateStateMetrics(data, 'APPOINTMENT:SYNC');

    final mapData = _parseData(data);
    if (mapData == null) return;

    final appointmentData = mapData['data'];
    if (appointmentData == null || appointmentData is! Map<String, dynamic>) {
      return;
    }
    final String appointmentId = appointmentData['id'];
    final lines = appointmentData['lines'];

    final appointmentsNotifier = _ref.read(
      appointmentsNotifierProvider.notifier,
    );
    final currentUserId = _ref.read(authNotifierProvider).user.id;

    if (lines is List && lines.isNotEmpty) {
      // Biến cờ: Đánh dấu xem có tìm thấy ít nhất 1 line của mình không
      bool foundAnyLineForMe = false;

      // Tạo thông tin Appointment Info dùng chung
      final appointmentInfoMap = {
        'id': appointmentData['id'],
        'appointmentTime': appointmentData['appointmentTime'],
        'status': appointmentData['status'],
        'note': appointmentData['note'],
        'customer': appointmentData['customer'],
      };

      //  Duyệt qua TẤT CẢ các line
      for (var line in lines) {
        if (line is Map<String, dynamic>) {
          final employeeId = line['employee']?['id'];

          // Nếu line này là của mình -> Xử lý cập nhật ngay
          if (employeeId == currentUserId) {
            foundAnyLineForMe = true; // Đánh dấu là có vé của mình

            try {
              // chuyển đổi JSON
              final constructedJson = {
                ...line,
                'appointment': appointmentInfoMap,
              };

              final model = AppointmentLineModel.fromJson(constructedJson);
              final entity = model.toEntity();

              if (kDebugMode) {
                print(
                  '[Socket] Upsert Line: ${entity.serviceName} (${entity.durationMinute}m)',
                );
              }
              // Gọi hàm update cho TỪNG line tìm thấy
              appointmentsNotifier.onAppointmentReceived(entity);
            } catch (e) {
              if (kDebugMode) print('[Socket] Parse Error: $e');
            }
          }
        }
      }

      // Sau khi chạy hết vòng lặp, nếu không tìm thấy dòng nào của mình
      // Nghĩa là mình đã bị xóa khỏi toàn bộ ticket này -> Xóa khỏi UI
      if (!foundAnyLineForMe) {
        if (kDebugMode) {
          print('[Socket] No lines for me in Appt $appointmentId -> REMOVE');
        }
        appointmentsNotifier.removeAppointment(appointmentId);
      }
    } else {
      // Trường hợp lines rỗng -> Xóa
      appointmentsNotifier.removeAppointment(appointmentId);
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
      if (kDebugMode) print('[Socket] Connected with user: $userFullName');
    } catch (e, stack) {
      state = state.copyWith(connectionStatus: AsyncValue.error(e, stack));
      if (kDebugMode) print('[Socket] Connection error: $e');
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
