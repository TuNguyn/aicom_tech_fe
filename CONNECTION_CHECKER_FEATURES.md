# Connection Checker - Complete Implementation Guide

> Reusable connection checker system for Flutter apps with Riverpod.
> Extracted from `aicom_tech_fe` project.

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Dependencies](#2-dependencies)
3. [Feature Details](#3-feature-details)
   - [3.1 ConnectivityService](#31-connectivityservice---core-service)
   - [3.2 ConnectivityState + Notifier](#32-connectivitystate--notifier---riverpod-state-management)
   - [3.3 ConnectivityBanner](#33-connectivitybanner---animated-ui)
   - [3.4 NetworkInterceptor](#34-networkinterceptor---dio-interceptor)
   - [3.5 DioClient Integration](#35-dioclient-integration---error-classification)
   - [3.6 Custom Exceptions](#36-custom-exceptions)
   - [3.7 Socket Disconnect When Offline](#37-socket-disconnect-when-offline)
   - [3.8 Auto-Recovery When Online](#38-auto-recovery-when-online)
   - [3.9 Toast Suppression](#39-toast-suppression-when-offline)
   - [3.10 DI Setup](#310-di-setup---provider-wiring)
4. [Data Flow Diagrams](#4-data-flow-diagrams)
5. [Implementation Checklist](#5-implementation-checklist-for-new-projects)

---

## 1. Architecture Overview

The system uses **dual-layer monitoring** to detect connectivity:

```
Layer 1: Interface Detection (connectivity_plus)
  - Detects WiFi/Cellular/Ethernet on/off
  - Fast detection but can give false positives (WiFi connected, no internet)

Layer 2: Internet Verification (internet_connection_checker)
  - Pings real servers to verify actual internet access
  - Slower but accurate

Combined: Interface off → immediately offline
          Interface on  → verify with internet checker → online/offline
```

### Feature Summary

| # | Feature | File |
|---|---------|------|
| 1 | **ConnectivityService** - Core dual-layer monitoring | `lib/core/network/connectivity_service.dart` |
| 2 | **ConnectivityState + Notifier** - Riverpod state, `justCameBackOnline` | `lib/presentation/providers/connectivity_provider.dart` |
| 3 | **ConnectivityBanner** - Animated pill banner, auto-hide 3s | `lib/presentation/widgets/connectivity_banner.dart` |
| 4 | **NetworkInterceptor** - Block HTTP when offline | `lib/core/network/network_interceptor.dart` |
| 5 | **DioClient integration** - Error classification (timeout/noConnection/serverError) | `lib/core/network/dio_client.dart` |
| 6 | **Custom exceptions** - `NetworkException` with `isOffline` flag | `lib/core/errors/exceptions.dart` |
| 7 | **Socket disconnect when offline** - Stop WebSocket retry loop | `lib/main.dart` |
| 8 | **Auto-recovery when online** - Reconnect socket + refresh data | `lib/main.dart` |
| 9 | **Toast suppression** - No error toast when offline (banner suffices) | Various pages |
| 10 | **DI setup** - Provider wiring | `lib/app_dependencies.dart` |

---

## 2. Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  connectivity_plus: ^6.1.4
  internet_connection_checker: ^3.0.1
  flutter_riverpod: ^2.x.x  # State management
  dio: ^5.x.x               # HTTP client
```

---

## 3. Feature Details

### 3.1 ConnectivityService - Core Service

**File:** `lib/core/network/connectivity_service.dart`

The core service that combines both packages into a single `ConnectivityStatus` stream.

```dart
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
```

**Key points:**
- Broadcast stream so multiple listeners can subscribe
- `_updateStatus` deduplicates (only emits when status actually changes)
- Constructor accepts optional params for testing/DI
- `currentStatus` getter for synchronous access (used by interceptor)

---

### 3.2 ConnectivityState + Notifier - Riverpod State Management

**File:** `lib/presentation/providers/connectivity_provider.dart`

Wraps the service in Riverpod with `previousStatus` tracking.

```dart
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
```

**Key points:**
- `justCameBackOnline` enables recovery logic (only true on offline->online transition)
- `previousStatus` is stored each time status changes
- Auto-initializes the service in constructor

---

### 3.3 ConnectivityBanner - Animated UI

**File:** `lib/presentation/widgets/connectivity_banner.dart`

Pill-shaped banner that slides in from top.

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app_dependencies.dart';
import '../providers/connectivity_provider.dart';
import '../theme/app_colors.dart';

class ConnectivityBanner extends ConsumerStatefulWidget {
  final Widget child;

  const ConnectivityBanner({super.key, required this.child});

  @override
  ConsumerState<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends ConsumerState<ConnectivityBanner> {
  bool _showBanner = false;
  bool _isOnline = true;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ConnectivityState>(connectivityNotifierProvider, (prev, next) {
      _hideTimer?.cancel();

      if (next.isOffline) {
        setState(() {
          _showBanner = true;
          _isOnline = false;
        });
      } else if (next.justCameBackOnline) {
        setState(() {
          _showBanner = true;
          _isOnline = true;
        });
        _hideTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() => _showBanner = false);
          }
        });
      }
    });

    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        widget.child,
        AnimatedPositioned(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          top: _showBanner ? topPadding + 4 : -(topPadding + 40),
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _isOnline ? AppColors.success : AppColors.error,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (_isOnline ? AppColors.success : AppColors.error)
                        .withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isOnline ? Icons.wifi : Icons.wifi_off_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isOnline ? 'Back online' : 'You are offline',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

**Key points:**
- Offline: red banner stays visible until back online
- Online: green "Back online" banner auto-hides after 3 seconds
- Uses `AnimatedPositioned` for smooth slide-in/out
- Pill shape with shadow for modern look
- Wraps entire app via `MaterialApp.router`'s `builder`

**Integration in `main.dart`:**
```dart
return MaterialApp.router(
  // ...
  builder: (context, child) {
    return ConnectivityBanner(child: child ?? const SizedBox.shrink());
  },
);
```

---

### 3.4 NetworkInterceptor - Dio Interceptor

**File:** `lib/core/network/network_interceptor.dart`

Blocks all HTTP requests immediately when device is offline.

```dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'connectivity_service.dart';

class NetworkInterceptor extends Interceptor {
  final ConnectivityService _connectivityService;

  NetworkInterceptor(this._connectivityService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_connectivityService.currentStatus == ConnectivityStatus.offline) {
      if (kDebugMode) {
        print('[NetworkInterceptor] Blocked - offline: ${options.path}');
      }
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          message: 'offline',
        ),
      );
    }
    super.onRequest(options, handler);
  }
}
```

**Key points:**
- Uses synchronous `currentStatus` check (no async delay)
- Rejects with `message: 'offline'` - this is the flag used downstream to identify interceptor-blocked requests vs real connection errors
- Prevents wasted timeout waits when obviously offline

---

### 3.5 DioClient Integration - Error Classification

**File:** `lib/core/network/dio_client.dart`

The `_handleDioException` method classifies errors into typed exceptions:

```dart
dynamic _handleDioException(DioException e) {
  if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
    throw AuthException(
      message: e.response?.data?['message'] ?? 'Authentication failed',
      statusCode: e.response?.statusCode,
    );
  }

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
      throw NetworkException(
        networkErrorType: NetworkErrorType.timeout,
        message: 'Connection timeout. Please check your network.',
      );

    case DioExceptionType.receiveTimeout:
      throw NetworkException(
        networkErrorType: NetworkErrorType.timeout,
        message: 'Server is taking too long to respond. Please try again later.',
      );

    case DioExceptionType.connectionError:
      final isOffline = e.message == 'offline';
      throw NetworkException(
        networkErrorType: NetworkErrorType.noConnection,
        message: isOffline
            ? 'No internet connection'
            : 'No internet connection. Please check your settings.',
        isOffline: isOffline,
      );

    case DioExceptionType.badResponse:
      if ((e.response?.statusCode ?? 0) >= 500) {
        throw NetworkException(
          networkErrorType: NetworkErrorType.serverError,
          message: e.response?.data?['message'] ?? 'Server error occurred',
        );
      }
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Request failed',
        statusCode: e.response?.statusCode,
      );

    case DioExceptionType.cancel:
      throw ServerException(message: 'Request cancelled');

    default:
      throw ServerException(
        message: e.response?.data?['message'] ?? 'An unknown error occurred',
      );
  }
}
```

**Error flow:**
```
NetworkInterceptor rejects with message='offline'
  → DioExceptionType.connectionError
    → e.message == 'offline' → isOffline = true
      → NetworkException(isOffline: true)
        → UI can check isOffline to suppress toast
```

**DioClient constructor wires the interceptor:**
```dart
DioClient(this._dio, {ConnectivityService? connectivityService})
    : _connectivityService = connectivityService {
  if (_connectivityService != null) {
    _dio.interceptors.add(NetworkInterceptor(_connectivityService));
  }
  // ... other config
}
```

---

### 3.6 Custom Exceptions

**File:** `lib/core/errors/exceptions.dart`

```dart
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException({required this.message, this.statusCode});
}

class AuthException extends ServerException {
  AuthException({required super.message, super.statusCode});
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}

enum NetworkErrorType {
  noConnection,
  serverError,
  timeout,
  unknown,
}

class NetworkException extends ServerException {
  final NetworkErrorType networkErrorType;
  final bool isOffline;

  NetworkException({
    required this.networkErrorType,
    required super.message,
    this.isOffline = false,
    super.statusCode,
  });
}
```

**Key points:**
- `NetworkException.isOffline` distinguishes interceptor-blocked requests from real network failures
- `NetworkErrorType` enum enables UI to show different messages per error type
- Hierarchy: `ServerException` -> `AuthException` / `NetworkException`

---

### 3.7 Socket Disconnect When Offline

**File:** `lib/main.dart` (lines 71-76)

```dart
ref.listen<ConnectivityState>(connectivityNotifierProvider, (prev, next) {
  // Disconnect socket when going offline to stop retry loop
  if (next.isOffline) {
    ref.read(socketNotifierProvider.notifier).disconnect();
    return;
  }
  // ...
});
```

**Why:** Socket.IO has built-in reconnection logic. If the device is offline, the socket will endlessly retry connections, wasting resources and potentially causing errors. Explicitly disconnecting prevents this.

**Socket provider also guards against connecting while offline:**
```dart
// In SocketNotifier.connect():
void connect(String authToken, String userFullName) {
  final connectivityState = _ref.read(connectivityNotifierProvider);
  if (connectivityState.isOffline) {
    if (kDebugMode) print('[Socket] Skipping connect - device is offline');
    return;
  }
  // ... proceed with connection
}
```

---

### 3.8 Auto-Recovery When Online

**File:** `lib/main.dart` (lines 79-93)

```dart
// Auto-recovery when coming back online
if (next.justCameBackOnline) {
  final authState = ref.read(authNotifierProvider);
  if (authState.isAuthenticated && authState.user.token.isNotEmpty) {
    // Reconnect socket
    ref
        .read(socketNotifierProvider.notifier)
        .connect(authState.user.token, authState.user.fullName);
    // Reload data
    ref.read(appointmentsNotifierProvider.notifier).fetchTodayCount();
    ref.read(walkInsNotifierProvider.notifier).refreshWalkIns();
    // Reset reports so next visit fetches fresh data
    ref.invalidate(reportsNotifierProvider);
  }
}
```

**Recovery actions:**
1. Reconnect WebSocket (real-time updates resume)
2. Refresh appointments data
3. Refresh walk-ins data
4. Invalidate reports (lazy refresh on next visit)

---

### 3.9 Toast Suppression When Offline

**Pattern used across all pages:**

```dart
// Skip toast when offline - banner already shows connectivity status
if (ref.read(connectivityNotifierProvider).isOffline) return;
ToastUtils.showError(error.toString());
```

**Files using this pattern:**
- `lib/presentation/pages/auth/login_page.dart`
- `lib/presentation/pages/auth/store_selection_page.dart`
- `lib/presentation/pages/appointments/appointments_page.dart`
- `lib/presentation/pages/walk_in/walk_in_page.dart`
- `lib/presentation/pages/profile/edit_profile_page.dart`
- `lib/presentation/widgets/walk_in_line_card.dart`

**Why:** When offline, the `ConnectivityBanner` already tells the user they're offline. Showing additional "No internet connection" error toasts for every failed request would be noisy and redundant.

---

### 3.10 DI Setup - Provider Wiring

**File:** `lib/app_dependencies.dart`

```dart
// Connectivity providers
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final connectivityNotifierProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
      return ConnectivityNotifier(ref.read(connectivityServiceProvider));
    });

// DioClient receives ConnectivityService for the interceptor
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    ref.read(dioProvider),
    connectivityService: ref.read(connectivityServiceProvider),
  );
});
```

**Dependency graph:**
```
connectivityServiceProvider
  ├── connectivityNotifierProvider (for UI + listeners)
  └── dioClientProvider → NetworkInterceptor (for HTTP blocking)
```

---

## 4. Data Flow Diagrams

### Device Goes Offline

```
WiFi/Cellular turns off
  │
  ├── connectivity_plus detects interface loss
  │     └── ConnectivityService._updateStatus(offline)
  │           └── statusStream emits offline
  │                 └── ConnectivityNotifier updates state
  │                       ├── ConnectivityBanner shows "You are offline" (red)
  │                       ├── main.dart listener disconnects socket
  │                       └── currentStatus = offline (sync)
  │
  └── Any HTTP request via DioClient
        └── NetworkInterceptor checks currentStatus
              └── offline → reject with message='offline'
                    └── DioClient._handleDioException
                          └── throws NetworkException(isOffline: true)
                                └── Page catches error
                                      └── checks isOffline → suppresses toast
```

### Device Comes Back Online

```
WiFi/Cellular reconnects
  │
  ├── connectivity_plus detects interface
  │     └── internet_connection_checker verifies internet
  │           └── ConnectivityService._updateStatus(online)
  │                 └── statusStream emits online
  │                       └── ConnectivityNotifier updates state
  │                             previousStatus=offline, status=online
  │                             justCameBackOnline = true
  │                               │
  │                               ├── ConnectivityBanner shows "Back online" (green)
  │                               │     └── auto-hides after 3 seconds
  │                               │
  │                               └── main.dart listener triggers recovery
  │                                     ├── socket.connect(token, name)
  │                                     ├── appointments.fetchTodayCount()
  │                                     ├── walkIns.refreshWalkIns()
  │                                     └── invalidate(reportsNotifier)
  │
  └── NetworkInterceptor now allows requests through
        └── Normal HTTP flow resumes
```

---

## 5. Implementation Checklist for New Projects

### Step 1: Add Dependencies
```yaml
# pubspec.yaml
dependencies:
  connectivity_plus: ^6.1.4
  internet_connection_checker: ^3.0.1
```

### Step 2: Create Core Files
- [ ] `lib/core/network/connectivity_service.dart` - Copy [Section 3.1](#31-connectivityservice---core-service)
- [ ] `lib/core/errors/exceptions.dart` - Add `NetworkException`, `NetworkErrorType` from [Section 3.6](#36-custom-exceptions)
- [ ] `lib/core/network/network_interceptor.dart` - Copy [Section 3.4](#34-networkinterceptor---dio-interceptor)

### Step 3: Create State Management
- [ ] `lib/presentation/providers/connectivity_provider.dart` - Copy [Section 3.2](#32-connectivitystate--notifier---riverpod-state-management)

### Step 4: Create UI
- [ ] `lib/presentation/widgets/connectivity_banner.dart` - Copy [Section 3.3](#33-connectivitybanner---animated-ui)
- [ ] Adjust colors (`AppColors.success`, `AppColors.error`) to match your theme

### Step 5: Wire DI
- [ ] Register `connectivityServiceProvider` in your DI file
- [ ] Register `connectivityNotifierProvider` in your DI file
- [ ] Pass `ConnectivityService` to `DioClient` constructor

### Step 6: Integrate in App
- [ ] Wrap app with `ConnectivityBanner` in `MaterialApp.builder`
- [ ] Add offline socket disconnect listener in root widget
- [ ] Add online recovery listener in root widget (reconnect socket, refresh data)

### Step 7: Update Error Handling
- [ ] Update `DioClient._handleDioException` to detect `isOffline` flag
- [ ] Add toast suppression pattern in all error handlers:
  ```dart
  if (ref.read(connectivityNotifierProvider).isOffline) return;
  ToastUtils.showError(error.toString());
  ```

### Step 8: Test
- [ ] Turn off WiFi → banner shows "You are offline"
- [ ] Tap any action → no error toast (suppressed)
- [ ] Turn on WiFi → banner shows "Back online" for 3s
- [ ] Socket reconnects automatically
- [ ] Data refreshes automatically
- [ ] HTTP requests work normally again
