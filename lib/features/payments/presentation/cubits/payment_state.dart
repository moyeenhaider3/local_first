import 'package:equatable/equatable.dart';
import 'package:local_first/features/payments/domain/entities/payment_entity.dart';

/// Abstract base class for all payment feature states.
sealed class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

/// Initial state of the [PaymentCubit].
final class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

/// State indicating an active asynchronous payment operation.
final class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

/// State indicating successful retrieval of payment details.
final class PaymentLoaded extends PaymentState {
  /// The loaded payment entity.
  final PaymentEntity? payment;

  /// Creates a [PaymentLoaded] state.
  const PaymentLoaded(this.payment);

  @override
  List<Object?> get props => [payment];
}

/// State indicating funds have been successfully locked in escrow.
final class PaymentEscrowHeld extends PaymentState {
  /// The updated payment entity in escrow status.
  final PaymentEntity payment;

  /// Creates a [PaymentEscrowHeld] state.
  const PaymentEscrowHeld(this.payment);

  @override
  List<Object?> get props => [payment];
}

/// State indicating payout has been released to the owner.
final class PaymentPayoutReleased extends PaymentState {
  /// Associated agreement ID.
  final String agreementId;

  /// Net payout amount released to owner.
  final double ownerPayout;

  /// Creates a [PaymentPayoutReleased] state.
  const PaymentPayoutReleased({
    required this.agreementId,
    required this.ownerPayout,
  });

  @override
  List<Object?> get props => [agreementId, ownerPayout];
}

/// State indicating a refund or dispute payout was processed.
final class PaymentRefundProcessed extends PaymentState {
  /// Associated agreement ID.
  final String agreementId;

  /// Amount refunded.
  final double refundAmount;

  /// Creates a [PaymentRefundProcessed] state.
  const PaymentRefundProcessed({
    required this.agreementId,
    required this.refundAmount,
  });

  @override
  List<Object?> get props => [agreementId, refundAmount];
}

/// State indicating a failure during a payment operation.
final class PaymentError extends PaymentState {
  /// User-friendly error message.
  final String message;

  /// Creates a [PaymentError] state.
  const PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}
