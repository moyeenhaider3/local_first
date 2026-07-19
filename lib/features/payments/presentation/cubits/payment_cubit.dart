import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_first/features/payments/domain/entities/payment_entity.dart';
import 'package:local_first/features/payments/domain/repositories/payment_repository.dart';
import 'package:local_first/features/payments/presentation/cubits/payment_state.dart';

/// Cubit responsible for managing payment escrow holds, status streams, payout release, and dispute refunds.
class PaymentCubit extends Cubit<PaymentState> {
  /// Repository reference.
  final PaymentRepository _repository;

  /// Stream subscription for real-time payment snapshot stream.
  StreamSubscription<PaymentEntity?>? _paymentSubscription;

  /// Creates a [PaymentCubit] instance.
  PaymentCubit(this._repository) : super(const PaymentInitial());

  /// Subscribes to real-time payment state changes for [agreementId].
  void watchPayment(String agreementId) {
    emit(const PaymentLoading());
    _paymentSubscription?.cancel();
    _paymentSubscription = _repository.watchPaymentForAgreement(agreementId).listen(
      (payment) {
        emit(PaymentLoaded(payment));
      },
      onError: (error) {
        emit(PaymentError(error.toString()));
      },
    );
  }

  /// Locks payment funds in escrow with proof upload and remarks.
  Future<void> holdPaymentInEscrow({
    required String agreementId,
    required double totalAmount,
    required double amountPaid,
    String? remarks,
    String? localImagePath,
    required String paymentMethod,
  }) async {
    emit(const PaymentLoading());

    String? proofUrl;
    if (localImagePath != null && localImagePath.isNotEmpty) {
      final uploadResult = await _repository.uploadPaymentProofImage(
        agreementId: agreementId,
        imagePath: localImagePath,
      );
      final urlOrFailure = uploadResult.fold(
        (failure) => null,
        (url) => url,
      );
      if (urlOrFailure != null) {
        proofUrl = urlOrFailure;
      }
    }

    final result = await _repository.holdPaymentInEscrow(
      agreementId: agreementId,
      totalAmount: totalAmount,
      amountPaid: amountPaid,
      remarks: remarks,
      proofUrl: proofUrl,
      paymentMethod: paymentMethod,
    );

    result.fold(
      (failure) => emit(PaymentError(failure.message)),
      (payment) => emit(PaymentEscrowHeld(payment)),
    );
  }

  /// Triggers escrow payout release to the owner.
  Future<void> releaseEscrowPayout(String agreementId) async {
    emit(const PaymentLoading());

    final result = await _repository.releaseEscrowPayout(agreementId: agreementId);

    result.fold(
      (failure) => emit(PaymentError(failure.message)),
      (_) => emit(PaymentPayoutReleased(
        agreementId: agreementId,
        ownerPayout: 0.0,
      )),
    );
  }

  /// Triggers dispute refund processing.
  Future<void> processDisputeRefund({
    required String agreementId,
    required double refundAmount,
    String? reason,
  }) async {
    emit(const PaymentLoading());

    final result = await _repository.processDisputeRefund(
      agreementId: agreementId,
      refundAmount: refundAmount,
      reason: reason,
    );

    result.fold(
      (failure) => emit(PaymentError(failure.message)),
      (_) => emit(PaymentRefundProcessed(
        agreementId: agreementId,
        refundAmount: refundAmount,
      )),
    );
  }

  @override
  Future<void> close() {
    _paymentSubscription?.cancel();
    return super.close();
  }
}
