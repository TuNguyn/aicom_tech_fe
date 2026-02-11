import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

enum ConnectivityStatus { online, offline }

class ConnectivityService {
  final Connectivity _connectivity;
  final InternetConnectionChecker _internetChecker;

  ConnectivityStatus _currentStatus = ConnectivityStatus.online;
  ConnectivityStatus get currentStatus => _currentStatus;

  final _statusController = StreamController<ConnectivityStatus>.broadcast();
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  StreamSubscription<InternetConnectionStatus>? _internetSub;

  ConnectivityService({
    Connectivity? connectivity,
    InternetConnectionChecker? internetChecker,
  })  : _connectivity = connectivity ?? Connectivity(),
        _internetChecker = internetChecker ?? InternetConnectionChecker.instance;

  Future<void> initialize() async {
    // Check initial status
    final results = await _connectivity.checkConnectivity();
    final hasInterface = !results.contains(ConnectivityResult.none);

    if (!hasInterface) {
      _updateStatus(ConnectivityStatus.offline);
    } else {
      final hasInternet = await _internetChecker.hasConnection;
      _updateStatus(
        hasInternet ? ConnectivityStatus.online : ConnectivityStatus.offline,
      );
    }

    // Listen for connectivity changes (WiFi/cellular on/off)
    _connectivitySub = _connectivity.onConnectivityChanged.listen(
      (results) async {
        final hasInterface = !results.contains(ConnectivityResult.none);

        if (!hasInterface) {
          _updateStatus(ConnectivityStatus.offline);
        } else {
          // Interface available, verify actual internet
          final hasInternet = await _internetChecker.hasConnection;
          _updateStatus(
            hasInternet ? ConnectivityStatus.online : ConnectivityStatus.offline,
          );
        }
      },
    );

    // Listen for internet connection changes (real connectivity verification)
    _internetSub = _internetChecker.onStatusChange.listen((status) {
      _updateStatus(
        status == InternetConnectionStatus.disconnected
            ? ConnectivityStatus.offline
            : ConnectivityStatus.online,
      );
    });
  }

  void _updateStatus(ConnectivityStatus newStatus) {
    if (_currentStatus != newStatus) {
      _currentStatus = newStatus;
      _statusController.add(newStatus);
      if (kDebugMode) {
        print('[Connectivity] Status changed: ${newStatus.name}');
      }
    }
  }

  void dispose() {
    _connectivitySub?.cancel();
    _internetSub?.cancel();
    _statusController.close();
  }
}
