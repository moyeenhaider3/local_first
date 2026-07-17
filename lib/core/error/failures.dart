import 'package:equatable/equatable.dart';

/// Base Failure class representing business/domain level errors.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Failure resulting from server errors or Firestore/Storage mutations.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred.']);
}

/// Failure resulting from authentication or verification operations.
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

/// Failure resulting from local cache or preferences access.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache operation failed.']);
}
