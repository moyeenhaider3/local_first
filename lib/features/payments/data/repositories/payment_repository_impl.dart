import 'package:dartz/dartz.dart';
import 'package:local_first/core/error/failures.dart';
import 'package:local_first/features/payments/data/datasources/payment_remote_datasource.dart';
import 'package:local_first/features/payments/domain/entities/payment_entity.dart';
import 'package:local_first/features/payments/domain/repositories/payment_repository.dart';

/// Concrete implementation of [PaymentRepository] interacting with [PaymentRemoteDatasource].
class PaymentRepositoryImpl implements PaymentRepository {
  /// Remote data source instance.
  final PaymentRemoteDatasource remoteDatasource;

  /// Creates a [PaymentRepositoryImpl] instance.
  PaymentRepositoryImpl(this.remoteDatasource);

  @override
  Stream<PaymentEntity?> watchPaymentForAgreement(String agreementId) {
    return remoteDatasource.watchPaymentForAgreement(agreementId);
  }

  @override
  Future<Either<Failure, PaymentEntity?>> getPaymentForAgreement(String agreementId) async {
    try {
      final payment = await remoteDatasource.fetchPaymentForAgreement(agreementId);
      return Right(payment);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadPaymentProofImage({
    required String agreementId,
    required String imagePath,
  }) async {
    try {
      final url = await remoteDatasource.uploadPaymentProofImage(
        agreementId: agreementId,
        imagePath: imagePath,
      );
      return Right(url);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> holdPaymentInEscrow({
    required String agreementId,
    required double totalAmount,
    required double amountPaid,
    String? remarks,
    String? proofUrl,
    required String paymentMethod,
  }) async {
    try {
      final payment = await remoteDatasource.holdPaymentInEscrow(
        agreementId: agreementId,
        totalAmount: totalAmount,
        amountPaid: amountPaid,
        remarks: remarks,
        proofUrl: proofUrl,
        paymentMethod: paymentMethod,
      );
      return Right(payment);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> releaseEscrowPayout({
    required String agreementId,
  }) async {
    try {
      await remoteDatasource.releaseEscrowPayout(agreementId: agreementId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> processDisputeRefund({
    required String agreementId,
    required double refundAmount,
    String? reason,
  }) async {
    try {
      await remoteDatasource.processDisputeRefund(
        agreementId: agreementId,
        refundAmount: refundAmount,
        reason: reason,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
