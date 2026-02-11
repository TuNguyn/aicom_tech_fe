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
