import 'package:equatable/equatable.dart';

/// Defines the type of task undergoing verification in the Local First app.
enum VerificationTaskType {
  /// Inspection at the time of pickup.
  pickupInspection,

  /// Settlement of payments.
  paymentSettlement,

  /// Handover back to owner when returning the item.
  itemReturn,

  /// Mark completion of service/work.
  serviceCompletion,

  /// Agreement and settlement on damages.
  damageSettlement,

  /// Initial security deposit payment.
  depositPayment,

  /// Return of the security deposit.
  depositReturn,

  /// Periodic payment cycle of a subscription.
  subscriptionCycle,
}

/// Represents the status of the verification lifecycle.
enum VerificationStatus {
  /// The task is created and waiting for action.
  pending,

  /// The initiator has confirmed the action and generated the code.
  initiatorConfirmed,

  /// The code has been successfully verified.
  verified,

  /// The code entry was rejected (e.g. maximum incorrect attempts).
  rejected,

  /// The task has expired before completion.
  expired,

  /// A dispute was raised during this verification step.
  disputed,

  /// The dispute or issues have been resolved.
  resolved,

  /// The verification process was cancelled.
  cancelled,
}

/// Domain entity representing a Verification Task in the Local First app.
class VerificationTaskEntity extends Equatable {
  /// The unique identifier of the verification task.
  final String id;

  /// The ID of the associated agreement.
  final String agreementId;

  /// The type of verification task.
  final VerificationTaskType taskType;

  /// The current lifecycle status of this verification task.
  final VerificationStatus status;

  /// The user ID of the code holder (initiator).
  final String initiatedById;

  /// The user ID of the code verifier (counterparty entering code).
  final String verifierId;

  /// SHA-256 hash of the verification code.
  final String codeHash;

  /// The number of failed attempts so far.
  final int attemptsUsed;

  /// The maximum attempts allowed (typically 5).
  final int maxAttempts;

  /// The expiration timestamp of the verification code.
  final DateTime expiresAt;

  /// The declared amount if the task relates to payments.
  final double? declaredAmount;

  /// The payment reference (e.g. UPI transaction ID) if applicable.
  final String? paymentReference;

  /// Additional comments or notes.
  final String? remark;

  /// Timestamp when the task was completed.
  final DateTime? completedAt;

  /// Timestamp when the task was created.
  final DateTime createdAt;

  /// Creates a [VerificationTaskEntity] instance.
  const VerificationTaskEntity({
    required this.id,
    required this.agreementId,
    required this.taskType,
    required this.status,
    required this.initiatedById,
    required this.verifierId,
    required this.codeHash,
    required this.attemptsUsed,
    required this.maxAttempts,
    required this.expiresAt,
    this.declaredAmount,
    this.paymentReference,
    this.remark,
    this.completedAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        agreementId,
        taskType,
        status,
        initiatedById,
        verifierId,
        codeHash,
        attemptsUsed,
        maxAttempts,
        expiresAt,
        declaredAmount,
        paymentReference,
        remark,
        completedAt,
        createdAt,
      ];
}
