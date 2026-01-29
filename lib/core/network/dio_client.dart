import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../config/app_config.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

class DioClient {
  final Dio _dio;

  DioClient(this._dio) {
    _dio
      ..options.baseUrl = AppConfig.baseUrl
      ..options.connectTimeout = const Duration(seconds: 30)
      ..options.receiveTimeout = const Duration(seconds: 30)
      ..options.headers = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

    // Add logging interceptor (only in debug mode)
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          // ignore: avoid_print
          logPrint: (log) => print('[DIO] $log'),
        ),
      );
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final authBox = Hive.box(AppConstants.authBoxName);
          final token = authBox.get(AppConstants.jwtTokenKey);

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            // ignore: avoid_print
            print('[DioClient] ${options.method} ${options.baseUrl}${options.path}');
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (kDebugMode) {
            // ignore: avoid_print
            print('[DioClient] Error: ${error.type} - ${error.message}');
          }
          if (error.response?.statusCode == 401) {
            // Handle 401 - clear auth and redirect to login
            final authBox = Hive.box(AppConstants.authBoxName);
            await authBox.clear();
          }
          return handler.next(error);
        },
      ),
    );
  }

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
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        throw NetworkException(
          networkErrorType: NetworkErrorType.noConnection,
          message: 'No internet connection',
        );

      case DioExceptionType.badResponse:
        if ((e.response?.statusCode ?? 0) >= 500) {
          throw NetworkException(
            networkErrorType: NetworkErrorType.serverError,
            message: e.response?.data?['message'] ?? 'Server error occurred',
          );
        }
        break;

      default:
        throw ServerException(
          message: e.response?.data?['message'] ?? 'An error occurred',
        );
    }
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response> patch(String path, {dynamic data}) async {
    try {
      final response = await _dio.patch(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }
}
