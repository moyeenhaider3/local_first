import 'package:dartz/dartz.dart';
import 'package:local_first/core/error/failures.dart';
import 'package:local_first/features/payments/domain/entities/payment_entity.dart';

/// Domain repository interface for payment and escrow operations in Local First.
abstract class PaymentRepository {
  /// Subscribes to real-time updates for a payment record linked to [agreementId].
  Stream<PaymentEntity?> watchPaymentForAgreement(String agreementId);

  /// Retrieves a payment record for [agreementId].
  Future<Either<Failure, PaymentEntity?>> getPaymentForAgreement(String agreementId);

  /// Uploads a payment proof image screenshot to Firebase Storage.
  Future<Either<Failure, String>> uploadPaymentProofImage({
    required String agreementId,
    required String imagePath,
  });

  /// Locks payment funds into escrow.
  Future<Either<Failure, PaymentEntity>> holdPaymentInEscrow({
    required String agreementId,
    required double totalAmount,
    required double amountPaid,
    String? remarks,
    String? proofUrl,
    required String paymentMethod,
  });

  /// Releases escrow payout to the owner with platform fee deduction.
  Future<Either<Failure, void>> releaseEscrowPayout({
    required String agreementId,
  });

  /// Processes a refund or dispute payout.
  Future<Either<Failure, void>> processDisputeRefund({
    required String agreementId,
    required double refundAmount,
    String? reason,
  });
}
