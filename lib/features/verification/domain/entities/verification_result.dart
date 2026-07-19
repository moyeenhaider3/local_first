import 'package:equatable/equatable.dart';

/// Value object representing the outcome of a code verification attempt.
class VerificationResult extends Equatable {
  /// Whether the verification attempt was successful.
  final bool verified;

  /// The number of verification attempts remaining.
  final int attemptsRemaining;

  /// A message from the server describing the status or error.
  final String message;

  /// Creates a [VerificationResult] instance.
  const VerificationResult({
    required this.verified,
    required this.attemptsRemaining,
    required this.message,
  });

  @override
  List<Object?> get props => [verified, attemptsRemaining, message];
}
