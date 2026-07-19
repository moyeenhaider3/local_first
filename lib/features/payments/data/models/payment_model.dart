import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_first/features/payments/domain/entities/payment_entity.dart';

/// Data model representing a payment record with JSON and Firestore serialization.
class PaymentModel extends PaymentEntity {
  /// Creates a [PaymentModel] instance.
  const PaymentModel({
    required super.id,
    required super.agreementId,
    required super.renterId,
    required super.ownerId,
    required super.totalAmount,
    required super.amountPaid,
    super.remarks,
    super.proofUrl,
    required super.platformFee,
    required super.ownerPayout,
    required super.currency,
    required super.status,
    required super.paymentMethod,
    super.transactionId,
    required super.createdAt,
    super.releasedAt,
  });

  /// Factory constructor to create a [PaymentModel] from a JSON map.
  factory PaymentModel.fromJson(Map<String, dynamic> json, String docId) {
    return PaymentModel(
      id: docId,
      agreementId: json['agreementId'] as String? ?? '',
      renterId: json['renterId'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 0.0,
      remarks: json['remarks'] as String?,
      proofUrl: json['proofUrl'] as String?,
      platformFee: (json['platformFee'] as num?)?.toDouble() ?? 0.0,
      ownerPayout: (json['ownerPayout'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      status: _parseStatus(json['status'] as String?),
      paymentMethod: json['paymentMethod'] as String? ?? 'Escrow',
      transactionId: json['transactionId'] as String?,
      createdAt: _parseDateTime(json['createdAt']),
      releasedAt: json['releasedAt'] != null ? _parseDateTime(json['releasedAt']) : null,
    );
  }

  /// Factory constructor to create a [PaymentModel] from a Firestore [DocumentSnapshot].
  factory PaymentModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return PaymentModel.fromJson(data, snapshot.id);
  }

  /// Converts this model instance into a JSON map for Firestore storage.
  Map<String, dynamic> toFirestore() {
    return {
      'agreementId': agreementId,
      'renterId': renterId,
      'ownerId': ownerId,
      'totalAmount': totalAmount,
      'amountPaid': amountPaid,
      'remarks': remarks,
      'proofUrl': proofUrl,
      'platformFee': platformFee,
      'ownerPayout': ownerPayout,
      'currency': currency,
      'status': status.name,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'createdAt': Timestamp.fromDate(createdAt),
      'releasedAt': releasedAt != null ? Timestamp.fromDate(releasedAt!) : null,
    };
  }

  /// Helper method to parse [PaymentStatus] from a string name.
  static PaymentStatus _parseStatus(String? raw) {
    if (raw == null) return PaymentStatus.pending;
    return PaymentStatus.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => PaymentStatus.pending,
    );
  }

  /// Helper method to safely parse a [DateTime] from dynamic Firestore timestamps or string values.
  static DateTime _parseDateTime(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
    return DateTime.now();
  }
}
