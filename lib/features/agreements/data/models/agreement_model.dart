import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_first/features/agreements/domain/entities/agreement_entity.dart';

class AgreementModel extends AgreementEntity {
  const AgreementModel({
    required super.id,
    required super.requestId,
    required super.listingId,
    required super.listingTitle,
    super.listingThumbnailUrl,
    required super.initiatorId,
    required super.counterpartyId,
    required super.agreementType,
    required super.status,
    required super.templateVersion,
    required super.totalAmount,
    required super.depositAmount,
    required super.dailyRate,
    required super.startDate,
    required super.endDate,
    required super.durationDays,
    required super.contentHash,
    required super.version,
    required super.initiatorConsentStatus,
    required super.counterpartyConsentStatus,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Factory to convert a domain entity to a data model.
  factory AgreementModel.fromEntity(AgreementEntity entity) {
    return AgreementModel(
      id: entity.id,
      requestId: entity.requestId,
      listingId: entity.listingId,
      listingTitle: entity.listingTitle,
      listingThumbnailUrl: entity.listingThumbnailUrl,
      initiatorId: entity.initiatorId,
      counterpartyId: entity.counterpartyId,
      agreementType: entity.agreementType,
      status: entity.status,
      templateVersion: entity.templateVersion,
      totalAmount: entity.totalAmount,
      depositAmount: entity.depositAmount,
      dailyRate: entity.dailyRate,
      startDate: entity.startDate,
      endDate: entity.endDate,
      durationDays: entity.durationDays,
      contentHash: entity.contentHash,
      version: entity.version,
      initiatorConsentStatus: entity.initiatorConsentStatus,
      counterpartyConsentStatus: entity.counterpartyConsentStatus,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Factory to convert JSON from Firestore to a data model.
  factory AgreementModel.fromJson(Map<String, dynamic> json, {required String id}) {
    final start = json['startDate'];
    final end = json['endDate'];
    final created = json['createdAt'];
    final updated = json['updatedAt'];

    return AgreementModel(
      id: id,
      requestId: json['requestId'] as String? ?? '',
      listingId: json['listingId'] as String? ?? '',
      listingTitle: json['listingTitle'] as String? ?? '',
      listingThumbnailUrl: json['listingThumbnailUrl'] as String?,
      initiatorId: json['initiatorId'] as String? ?? '',
      counterpartyId: json['counterpartyId'] as String? ?? '',
      agreementType: (json['agreementType'] as String?) == 'service'
          ? AgreementType.service
          : AgreementType.rental,
      status: _parseStatus(json['status'] as String?),
      templateVersion: json['templateVersion'] as String? ?? 'rent-in-v1.0',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      depositAmount: (json['depositAmount'] as num?)?.toDouble() ?? 0.0,
      dailyRate: (json['dailyRate'] as num?)?.toDouble() ?? 0.0,
      startDate: start is Timestamp
          ? start.toDate()
          : (start is String ? DateTime.parse(start) : DateTime.now()),
      endDate: end is Timestamp
          ? end.toDate()
          : (end is String ? DateTime.parse(end) : DateTime.now()),
      durationDays: json['durationDays'] as int? ?? 0,
      contentHash: json['contentHash'] as String? ?? '',
      version: json['version'] as int? ?? 1,
      initiatorConsentStatus: (json['initiatorConsentStatus'] as String?) == 'accepted'
          ? ConsentStatus.accepted
          : ConsentStatus.pending,
      counterpartyConsentStatus: (json['counterpartyConsentStatus'] as String?) == 'accepted'
          ? ConsentStatus.accepted
          : ConsentStatus.pending,
      createdAt: created is Timestamp
          ? created.toDate()
          : (created is String ? DateTime.parse(created) : DateTime.now()),
      updatedAt: updated is Timestamp
          ? updated.toDate()
          : (updated is String ? DateTime.parse(updated) : DateTime.now()),
    );
  }

  static AgreementStatus _parseStatus(String? statusStr) {
    switch (statusStr) {
      case 'awaitingConsent':
        return AgreementStatus.awaitingConsent;
      case 'confirmed':
        return AgreementStatus.confirmed;
      case 'paymentPending':
        return AgreementStatus.paymentPending;
      case 'paymentDeclared':
        return AgreementStatus.paymentDeclared;
      case 'paymentVerified':
        return AgreementStatus.paymentVerified;
      case 'pickupPending':
        return AgreementStatus.pickupPending;
      case 'active':
        return AgreementStatus.active;
      case 'extensionPending':
        return AgreementStatus.extensionPending;
      case 'extended':
        return AgreementStatus.extended;
      case 'returnPending':
        return AgreementStatus.returnPending;
      case 'completed':
        return AgreementStatus.completed;
      case 'damageDisputed':
        return AgreementStatus.damageDisputed;
      case 'cancelled':
        return AgreementStatus.cancelled;
      case 'archived':
        return AgreementStatus.archived;
      case 'draft':
      default:
        return AgreementStatus.draft;
    }
  }

  /// Converts this model instance into a domain entity.
  AgreementEntity toEntity() {
    return AgreementEntity(
      id: id,
      requestId: requestId,
      listingId: listingId,
      listingTitle: listingTitle,
      listingThumbnailUrl: listingThumbnailUrl,
      initiatorId: initiatorId,
      counterpartyId: counterpartyId,
      agreementType: agreementType,
      status: status,
      templateVersion: templateVersion,
      totalAmount: totalAmount,
      depositAmount: depositAmount,
      dailyRate: dailyRate,
      startDate: startDate,
      endDate: endDate,
      durationDays: durationDays,
      contentHash: contentHash,
      version: version,
      initiatorConsentStatus: initiatorConsentStatus,
      counterpartyConsentStatus: counterpartyConsentStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Converts this model instance to a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'listingId': listingId,
      'listingTitle': listingTitle,
      'listingThumbnailUrl': listingThumbnailUrl,
      'initiatorId': initiatorId,
      'counterpartyId': counterpartyId,
      'agreementType': agreementType.name,
      'status': status.name,
      'templateVersion': templateVersion,
      'totalAmount': totalAmount,
      'depositAmount': depositAmount,
      'dailyRate': dailyRate,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'durationDays': durationDays,
      'contentHash': contentHash,
      'version': version,
      'initiatorConsentStatus': initiatorConsentStatus.name,
      'counterpartyConsentStatus': counterpartyConsentStatus.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
