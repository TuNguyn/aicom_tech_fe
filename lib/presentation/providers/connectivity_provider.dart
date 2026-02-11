import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/connectivity_service.dart';

class ConnectivityState {
  final ConnectivityStatus status;
  final ConnectivityStatus? previousStatus;

  const ConnectivityState({
    this.status = ConnectivityStatus.online,
    this.previousStatus,
  });

  bool get isOnline => status == ConnectivityStatus.online;
  bool get isOffline => status == ConnectivityStatus.offline;

  /// True when transitioning from offline to online
  bool get justCameBackOnline =>
      previousStatus == ConnectivityStatus.offline &&
      status == ConnectivityStatus.online;

  ConnectivityState copyWith({
    ConnectivityStatus? status,
    ConnectivityStatus? previousStatus,
  }) {
    return ConnectivityState(
      status: status ?? this.status,
      previousStatus: previousStatus ?? this.previousStatus,
    );
  }
}

class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  final ConnectivityService _service;
  StreamSubscription<ConnectivityStatus>? _subscription;

  ConnectivityNotifier(this._service) : super(const ConnectivityState()) {
    _init();
  }

  Future<void> _init() async {
    await _service.initialize();

    // Set initial status from service
    state = ConnectivityState(status: _service.currentStatus);

    _subscription = _service.statusStream.listen((newStatus) {
      state = ConnectivityState(
        status: newStatus,
        previousStatus: state.status,
      );
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _service.dispose();
    super.dispose();
  }
}
