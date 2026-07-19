import 'package:equatable/equatable.dart';

/// Represents the status of a payment transaction in Local First.
enum PaymentStatus {
  /// Payment has been initiated but not yet completed or held in escrow.
  pending,

  /// Payment funds are locked securely in escrow.
  escrowHeld,

  /// Escrow funds have been split and released to the owner.
  payoutReleased,

  /// Payment has been refunded to the renter.
  refunded,

  /// Payment payout is frozen due to an active dispute.
  disputed,
}

/// Domain entity representing a payment transaction record in Local First.
class PaymentEntity extends Equatable {
  /// Unique identifier of the payment.
  final String id;

  /// Associated rental agreement ID.
  final String agreementId;

  /// User ID of the renter who made the payment.
  final String renterId;

  /// User ID of the owner receiving the payout.
  final String ownerId;

  /// Total declared amount for the transaction.
  final double totalAmount;

  /// Actual amount paid by the renter.
  final double amountPaid;

  /// Optional payment reference notes or remarks.
  final String? remarks;

  /// Optional URL of the uploaded payment proof screenshot in Firebase Storage.
  final String? proofUrl;

  /// Calculated platform commission fee (e.g., 5%).
  final double platformFee;

  /// Net payout amount allocated to the owner (e.g., 95%).
  final double ownerPayout;

  /// Currency code (e.g., 'INR').
  final String currency;

  /// Current status of the payment.
  final PaymentStatus status;

  /// Payment method used (e.g., 'UPI', 'Card', 'Escrow').
  final String paymentMethod;

  /// External transaction reference ID if available.
  final String? transactionId;

  /// Timestamp when the payment record was created.
  final DateTime createdAt;

  /// Timestamp when the payout was released to the owner, if applicable.
  final DateTime? releasedAt;

  /// Creates a [PaymentEntity] instance.
  const PaymentEntity({
    required this.id,
    required this.agreementId,
    required this.renterId,
    required this.ownerId,
    required this.totalAmount,
    required this.amountPaid,
    this.remarks,
    this.proofUrl,
    required this.platformFee,
    required this.ownerPayout,
    required this.currency,
    required this.status,
    required this.paymentMethod,
    this.transactionId,
    required this.createdAt,
    this.releasedAt,
  });

  @override
  List<Object?> get props => [
        id,
        agreementId,
        renterId,
        ownerId,
        totalAmount,
        amountPaid,
        remarks,
        proofUrl,
        platformFee,
        ownerPayout,
        currency,
        status,
        paymentMethod,
        transactionId,
        createdAt,
        releasedAt,
      ];
}
