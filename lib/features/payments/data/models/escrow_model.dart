import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_first/features/payments/domain/entities/escrow_entity.dart';

/// Data model representing an escrow hold record with JSON and Firestore serialization.
class EscrowModel extends EscrowEntity {
  /// Creates an [EscrowModel] instance.
  const EscrowModel({
    required super.id,
    required super.agreementId,
    required super.totalHeld,
    required super.status,
    required super.heldAt,
    super.resolvedAt,
  });

  /// Factory constructor to create an [EscrowModel] from a JSON map.
  factory EscrowModel.fromJson(Map<String, dynamic> json, String docId) {
    return EscrowModel(
      id: docId,
      agreementId: json['agreementId'] as String? ?? '',
      totalHeld: (json['totalHeld'] as num?)?.toDouble() ?? 0.0,
      status: _parseStatus(json['status'] as String?),
      heldAt: _parseDateTime(json['heldAt']),
      resolvedAt: json['resolvedAt'] != null ? _parseDateTime(json['resolvedAt']) : null,
    );
  }

  /// Factory constructor to create an [EscrowModel] from a Firestore [DocumentSnapshot].
  factory EscrowModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return EscrowModel.fromJson(data, snapshot.id);
  }

  /// Converts this model instance into a JSON map for Firestore storage.
  Map<String, dynamic> toFirestore() {
    return {
      'agreementId': agreementId,
      'totalHeld': totalHeld,
      'status': status.name,
      'heldAt': Timestamp.fromDate(heldAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }

  /// Helper method to parse [EscrowStatus] from a string name.
  static EscrowStatus _parseStatus(String? raw) {
    if (raw == null) return EscrowStatus.held;
    return EscrowStatus.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => EscrowStatus.held,
    );
  }

  /// Helper method to parse a [DateTime] safely.
  static DateTime _parseDateTime(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
    return DateTime.now();
  }
}
