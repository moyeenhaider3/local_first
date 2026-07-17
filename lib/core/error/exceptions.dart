// Exceptions thrown by the data layer when accessing external services.

class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'A server error occurred.']);

  @override
  String toString() => 'ServerException: $message';
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'An authentication error occurred.']);

  @override
  String toString() => 'AuthException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'A cache operation failed.']);

  @override
  String toString() => 'CacheException: $message';
}
