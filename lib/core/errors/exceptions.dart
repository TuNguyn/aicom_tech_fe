class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (Code: $statusCode)';
}

class AuthException extends ServerException {
  AuthException({required super.message, super.statusCode});

  @override
  String toString() => 'AuthException: $message (Code: $statusCode)';
}

class CacheException implements Exception {
  final String message;

  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
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

  @override
  String toString() => 'NetworkException (${networkErrorType.name}): $message';
}
