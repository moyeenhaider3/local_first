import 'package:equatable/equatable.dart';

enum AgreementType { rental, service }

enum AgreementStatus {
  draft,
  awaitingConsent,
  confirmed,
  paymentPending,
  paymentDeclared,
  paymentVerified,
  pickupPending,
  active,
  extensionPending,
  extended,
  returnPending,
  completed,
  damageDisputed,
  cancelled,
  archived
}

enum ConsentStatus { pending, accepted }

/// Domain Layer: Agreement Entity
/// Represents a legal contract agreement between renter/initiator and owner/counterparty.
class AgreementEntity extends Equatable {
  final String id;
  final String requestId;
  final String listingId;
  final String listingTitle;
  final String? listingThumbnailUrl;
  final String initiatorId;
  final String counterpartyId;
  final AgreementType agreementType;
  final AgreementStatus status;
  final String templateVersion;
  final double totalAmount;
  final double depositAmount;
  final double dailyRate;
  final DateTime startDate;
  final DateTime endDate;
  final int durationDays;
  final String contentHash;
  final int version;
  final ConsentStatus initiatorConsentStatus;
  final ConsentStatus counterpartyConsentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AgreementEntity({
    required this.id,
    required this.requestId,
    required this.listingId,
    required this.listingTitle,
    this.listingThumbnailUrl,
    required this.initiatorId,
    required this.counterpartyId,
    required this.agreementType,
    required this.status,
    required this.templateVersion,
    required this.totalAmount,
    required this.depositAmount,
    required this.dailyRate,
    required this.startDate,
    required this.endDate,
    required this.durationDays,
    required this.contentHash,
    required this.version,
    required this.initiatorConsentStatus,
    required this.counterpartyConsentStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        requestId,
        listingId,
        listingTitle,
        listingThumbnailUrl,
        initiatorId,
        counterpartyId,
        agreementType,
        status,
        templateVersion,
        totalAmount,
        depositAmount,
        dailyRate,
        startDate,
        endDate,
        durationDays,
        contentHash,
        version,
        initiatorConsentStatus,
        counterpartyConsentStatus,
        createdAt,
        updatedAt,
      ];
}
