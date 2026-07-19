import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:local_first/features/payments/data/models/payment_model.dart';
import 'package:local_first/features/payments/domain/entities/payment_entity.dart';

/// Abstract datasource interface for handling payment and escrow operations remotely.
abstract class PaymentRemoteDatasource {
  /// Emits real-time updates for a payment record associated with the given [agreementId].
  Stream<PaymentEntity?> watchPaymentForAgreement(String agreementId);

  /// Fetches a payment record associated with the given [agreementId].
  Future<PaymentEntity?> fetchPaymentForAgreement(String agreementId);

  /// Uploads a payment proof image screenshot to Firebase Storage and returns its download URL.
  Future<String> uploadPaymentProofImage({
    required String agreementId,
    required String imagePath,
  });

  /// Initiates an escrow hold for the given agreement via Cloud Function.
  Future<PaymentEntity> holdPaymentInEscrow({
    required String agreementId,
    required double totalAmount,
    required double amountPaid,
    String? remarks,
    String? proofUrl,
    required String paymentMethod,
  });

  /// Releases escrow funds and calculates split payout for the owner via Cloud Function.
  Future<void> releaseEscrowPayout({
    required String agreementId,
  });

  /// Processes a refund or dispute resolution payout via Cloud Function.
  Future<void> processDisputeRefund({
    required String agreementId,
    required double refundAmount,
    String? reason,
  });
}

/// Firebase implementation of [PaymentRemoteDatasource].
class PaymentRemoteDatasourceImpl implements PaymentRemoteDatasource {
  /// Firestore instance for direct database queries.
  final FirebaseFirestore firestore;

  /// Firebase Functions instance for server-side state transitions.
  final FirebaseFunctions functions;

  /// Firebase Storage instance for proof screenshot uploads.
  final FirebaseStorage storage;

  /// Creates a [PaymentRemoteDatasourceImpl] instance.
  PaymentRemoteDatasourceImpl({
    required this.firestore,
    required this.functions,
    required this.storage,
  });

  @override
  Stream<PaymentEntity?> watchPaymentForAgreement(String agreementId) {
    return firestore
        .collection('payments')
        .where('agreementId', isEqualTo: agreementId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return PaymentModel.fromFirestore(snapshot.docs.first);
    });
  }

  @override
  Future<PaymentEntity?> fetchPaymentForAgreement(String agreementId) async {
    final query = await firestore
        .collection('payments')
        .where('agreementId', isEqualTo: agreementId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return PaymentModel.fromFirestore(query.docs.first);
  }

  @override
  Future<String> uploadPaymentProofImage({
    required String agreementId,
    required String imagePath,
  }) async {
    final file = File(imagePath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ref = storage.ref().child('payment_proofs/${agreementId}_$timestamp.jpg');

    final uploadTask = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Future<PaymentEntity> holdPaymentInEscrow({
    required String agreementId,
    required double totalAmount,
    required double amountPaid,
    String? remarks,
    String? proofUrl,
    required String paymentMethod,
  }) async {
    final callable = functions.httpsCallable('holdPaymentEscrow');
    final response = await callable.call({
      'agreementId': agreementId,
      'totalAmount': totalAmount,
      'amountPaid': amountPaid,
      'remarks': remarks,
      'proofUrl': proofUrl,
      'paymentMethod': paymentMethod,
    });

    final data = Map<String, dynamic>.from(response.data as Map);
    final paymentId = data['paymentId'] as String? ?? '';

    final paymentDoc = await firestore.collection('payments').doc(paymentId).get();
    if (paymentDoc.exists) {
      return PaymentModel.fromFirestore(paymentDoc);
    }

    return PaymentModel(
      id: paymentId,
      agreementId: agreementId,
      renterId: data['renterId'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      totalAmount: totalAmount,
      amountPaid: amountPaid,
      remarks: remarks,
      proofUrl: proofUrl,
      platformFee: totalAmount * 0.05,
      ownerPayout: totalAmount * 0.95,
      currency: 'INR',
      status: PaymentStatus.escrowHeld,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> releaseEscrowPayout({
    required String agreementId,
  }) async {
    final callable = functions.httpsCallable('releasePaymentPayout');
    await callable.call({
      'agreementId': agreementId,
    });
  }

  @override
  Future<void> processDisputeRefund({
    required String agreementId,
    required double refundAmount,
    String? reason,
  }) async {
    final callable = functions.httpsCallable('processRefundOrDisputePayout');
    await callable.call({
      'agreementId': agreementId,
      'refundAmount': refundAmount,
      'reason': reason,
    });
  }
}
