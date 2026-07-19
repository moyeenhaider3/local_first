import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_first/features/verification/domain/entities/verification_task_entity.dart';

/// Data model representing a Verification Task in the Local First app, extending the domain entity.
class VerificationTaskModel extends VerificationTaskEntity {
  /// Creates a [VerificationTaskModel] instance.
  const VerificationTaskModel({
    required super.id,
    required super.agreementId,
    required super.taskType,
    required super.status,
    required super.initiatedById,
    required super.verifierId,
    required super.codeHash,
    required super.attemptsUsed,
    required super.maxAttempts,
    required super.expiresAt,
    super.declaredAmount,
    super.paymentReference,
    super.remark,
    super.completedAt,
    required super.createdAt,
  });

  /// Factory to convert a domain entity [VerificationTaskEntity] to a [VerificationTaskModel].
  factory VerificationTaskModel.fromEntity(VerificationTaskEntity entity) {
    return VerificationTaskModel(
      id: entity.id,
      agreementId: entity.agreementId,
      taskType: entity.taskType,
      status: entity.status,
      initiatedById: entity.initiatedById,
      verifierId: entity.verifierId,
      codeHash: entity.codeHash,
      attemptsUsed: entity.attemptsUsed,
      maxAttempts: entity.maxAttempts,
      expiresAt: entity.expiresAt,
      declaredAmount: entity.declaredAmount,
      paymentReference: entity.paymentReference,
      remark: entity.remark,
      completedAt: entity.completedAt,
      createdAt: entity.createdAt,
    );
  }

  /// Factory to convert JSON from Firestore or an API into a [VerificationTaskModel].
  factory VerificationTaskModel.fromJson(Map<String, dynamic> json, {required String id}) {
    final expires = json['expiresAt'];
    final completed = json['completedAt'];
    final created = json['createdAt'];

    return VerificationTaskModel(
      id: id,
      agreementId: json['agreementId'] as String? ?? '',
      taskType: _parseTaskType(json['taskType'] as String?),
      status: _parseStatus(json['status'] as String?),
      initiatedById: json['initiatedById'] as String? ?? '',
      verifierId: json['verifierId'] as String? ?? '',
      codeHash: json['codeHash'] as String? ?? '',
      attemptsUsed: json['attemptsUsed'] as int? ?? 0,
      maxAttempts: json['maxAttempts'] as int? ?? 5,
      expiresAt: expires is Timestamp
          ? expires.toDate()
          : (expires is String ? DateTime.parse(expires) : DateTime.now()),
      declaredAmount: (json['declaredAmount'] as num?)?.toDouble(),
      paymentReference: json['paymentReference'] as String?,
      remark: json['remark'] as String?,
      completedAt: completed is Timestamp
          ? completed.toDate()
          : (completed is String ? DateTime.parse(completed) : null),
      createdAt: created is Timestamp
          ? created.toDate()
          : (created is String ? DateTime.parse(created) : DateTime.now()),
    );
  }

  /// Converts this model instance into a domain [VerificationTaskEntity].
  VerificationTaskEntity toEntity() {
    return VerificationTaskEntity(
      id: id,
      agreementId: agreementId,
      taskType: taskType,
      status: status,
      initiatedById: initiatedById,
      verifierId: verifierId,
      codeHash: codeHash,
      attemptsUsed: attemptsUsed,
      maxAttempts: maxAttempts,
      expiresAt: expiresAt,
      declaredAmount: declaredAmount,
      paymentReference: paymentReference,
      remark: remark,
      completedAt: completedAt,
      createdAt: createdAt,
    );
  }

  /// Converts this model instance to a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'agreementId': agreementId,
      'taskType': taskType.name,
      'status': status.name,
      'initiatedById': initiatedById,
      'verifierId': verifierId,
      'codeHash': codeHash,
      'attemptsUsed': attemptsUsed,
      'maxAttempts': maxAttempts,
      'expiresAt': expiresAt.toUtc().toIso8601String(),
      'declaredAmount': declaredAmount,
      'paymentReference': paymentReference,
      'remark': remark,
      'completedAt': completedAt?.toUtc().toIso8601String(),
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  /// Helper to parse task type enum.
  static VerificationTaskType _parseTaskType(String? typeStr) {
    switch (typeStr) {
      case 'pickupInspection':
        return VerificationTaskType.pickupInspection;
      case 'paymentSettlement':
        return VerificationTaskType.paymentSettlement;
      case 'itemReturn':
        return VerificationTaskType.itemReturn;
      case 'serviceCompletion':
        return VerificationTaskType.serviceCompletion;
      case 'damageSettlement':
        return VerificationTaskType.damageSettlement;
      case 'depositPayment':
        return VerificationTaskType.depositPayment;
      case 'depositReturn':
        return VerificationTaskType.depositReturn;
      case 'subscriptionCycle':
        return VerificationTaskType.subscriptionCycle;
      default:
        return VerificationTaskType.pickupInspection;
    }
  }

  /// Helper to parse status enum.
  static VerificationStatus _parseStatus(String? statusStr) {
    switch (statusStr) {
      case 'initiatorConfirmed':
        return VerificationStatus.initiatorConfirmed;
      case 'verified':
        return VerificationStatus.verified;
      case 'rejected':
        return VerificationStatus.rejected;
      case 'expired':
        return VerificationStatus.expired;
      case 'disputed':
        return VerificationStatus.disputed;
      case 'resolved':
        return VerificationStatus.resolved;
      case 'cancelled':
        return VerificationStatus.cancelled;
      case 'pending':
      default:
        return VerificationStatus.pending;
    }
  }
}
