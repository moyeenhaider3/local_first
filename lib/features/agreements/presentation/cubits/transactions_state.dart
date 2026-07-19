import 'package:equatable/equatable.dart';
import 'package:local_first/features/agreements/domain/entities/agreement_entity.dart';
import 'package:local_first/features/agreements/domain/entities/request_entity.dart';

/// Base state class for [TransactionsCubit].
abstract class TransactionsState extends Equatable {
  /// Base constructor for [TransactionsState].
  const TransactionsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before transaction history is fetched.
class TransactionsInitial extends TransactionsState {
  /// Creates a [TransactionsInitial] state.
  const TransactionsInitial();
}

/// Loading state while fetching transaction history from repository.
class TransactionsLoading extends TransactionsState {
  /// Creates a [TransactionsLoading] state.
  const TransactionsLoading();
}

/// Loaded state containing categorized lists of requests, active agreements, and completed agreements.
class TransactionsLoaded extends TransactionsState {
  /// List of inbound and outbound booking requests for the user.
  final List<RequestEntity> requests;

  /// List of agreements with active/in-progress statuses.
  final List<AgreementEntity> activeAgreements;

  /// List of agreements with completed/terminal statuses.
  final List<AgreementEntity> completedAgreements;

  /// Creates a [TransactionsLoaded] state.
  const TransactionsLoaded({
    required this.requests,
    required this.activeAgreements,
    required this.completedAgreements,
  });

  @override
  List<Object?> get props => [requests, activeAgreements, completedAgreements];
}

/// Error state emitted when fetching transactions fails.
class TransactionsError extends TransactionsState {
  /// Descriptive message explaining the failure.
  final String message;

  /// Creates a [TransactionsError] state instance.
  const TransactionsError(this.message);

  @override
  List<Object?> get props => [message];
}
