import 'package:equatable/equatable.dart';
import 'package:local_first/features/verification/domain/entities/verification_task_entity.dart';

/// Sealed class defining the 7 verification states in the Local First application.
sealed class VerificationState extends Equatable {
  /// Base constructor.
  const VerificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state prior to any verification operations.
class VerificationInitial extends VerificationState {
  /// Base constructor.
  const VerificationInitial();
}

/// Loading state while communicating with Firestore/Functions.
class VerificationLoading extends VerificationState {
  /// Base constructor.
  const VerificationLoading();
}

/// State when the verification code is successfully issued to the code holder.
class CodeIssued extends VerificationState {
  /// The generated plaintext code, or null if the user is not authorized to read it.
  final String? plaintextCode;

  /// Creates a [CodeIssued] state.
  const CodeIssued({this.plaintextCode});

  @override
  List<Object?> get props => [plaintextCode];
}

/// State while submitting and verifying the code server-side.
class CodeSubmitting extends VerificationState {
  /// Base constructor.
  const CodeSubmitting();
}

/// State when code verification succeeded, marking the handshake complete.
class CodeVerificationSuccess extends VerificationState {
  /// The updated verification task entity.
  final VerificationTaskEntity task;

  /// Creates a [CodeVerificationSuccess] state.
  const CodeVerificationSuccess({required this.task});

  @override
  List<Object?> get props => [task];
}

/// State when a code entry fails, providing remaining attempts and description.
class CodeVerificationFailure extends VerificationState {
  /// The number of attempts remaining.
  final int attemptsRemaining;

  /// Detailed verification error/status message.
  final String message;

  /// Creates a [CodeVerificationFailure] state.
  const CodeVerificationFailure({
    required this.attemptsRemaining,
    required this.message,
  });

  @override
  List<Object?> get props => [attemptsRemaining, message];
}

/// State when the verification task has passed its 30-minute expiry window.
class TaskExpired extends VerificationState {
  /// Base constructor.
  const TaskExpired();
}

/// General error state for unexpected server or operation issues.
class VerificationError extends VerificationState {
  /// The description of the error.
  final String message;

  /// Creates a [VerificationError] state.
  const VerificationError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State while submitting a damage dispute.
class DisputeSubmitting extends VerificationState {
  /// Base constructor.
  const DisputeSubmitting();
}

/// State when a damage dispute is successfully submitted.
class DisputeSuccess extends VerificationState {
  /// Base constructor.
  const DisputeSuccess();
}

