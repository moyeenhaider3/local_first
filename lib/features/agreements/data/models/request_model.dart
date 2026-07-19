import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_first/features/agreements/domain/entities/request_entity.dart';

class RequestModel extends RequestEntity {
  const RequestModel({
    required super.id,
    required super.listingId,
    required super.listingTitle,
    required super.requesterId,
    required super.receiverId,
    required super.requestType,
    required super.status,
    required super.proposedStartDate,
    super.proposedEndDate,
    super.proposedDurationDays,
    required super.estimatedTotal,
    super.estimatedDeposit,
    super.message,
    required super.expiresAt,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Factory to convert a domain entity to a data model.
  factory RequestModel.fromEntity(RequestEntity entity) {
    return RequestModel(
      id: entity.id,
      listingId: entity.listingId,
      listingTitle: entity.listingTitle,
      requesterId: entity.requesterId,
      receiverId: entity.receiverId,
      requestType: entity.requestType,
      status: entity.status,
      proposedStartDate: entity.proposedStartDate,
      proposedEndDate: entity.proposedEndDate,
      proposedDurationDays: entity.proposedDurationDays,
      estimatedTotal: entity.estimatedTotal,
      estimatedDeposit: entity.estimatedDeposit,
      message: entity.message,
      expiresAt: entity.expiresAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Factory to convert JSON from Firestore to a data model.
  factory RequestModel.fromJson(Map<String, dynamic> json, {required String id}) {
    final proposedStart = json['proposedStartDate'];
    final proposedEnd = json['proposedEndDate'];
    final expires = json['expiresAt'];
    final created = json['createdAt'];
    final updated = json['updatedAt'];

    return RequestModel(
      id: id,
      listingId: json['listingId'] as String? ?? '',
      listingTitle: json['listingTitle'] as String? ?? '',
      requesterId: json['requesterId'] as String? ?? '',
      receiverId: json['receiverId'] as String? ?? '',
      requestType: (json['requestType'] as String?) == 'service'
          ? RequestType.service
          : RequestType.rental,
      status: _parseStatus(json['status'] as String?),
      proposedStartDate: proposedStart is Timestamp
          ? proposedStart.toDate()
          : (proposedStart is String ? DateTime.parse(proposedStart) : DateTime.now()),
      proposedEndDate: proposedEnd is Timestamp
          ? proposedEnd.toDate()
          : (proposedEnd is String ? DateTime.parse(proposedEnd) : null),
      proposedDurationDays: json['proposedDurationDays'] as int?,
      estimatedTotal: (json['estimatedTotal'] as num?)?.toDouble() ?? 0.0,
      estimatedDeposit: (json['estimatedDeposit'] as num?)?.toDouble(),
      message: json['message'] as String?,
      expiresAt: expires is Timestamp
          ? expires.toDate()
          : (expires is String ? DateTime.parse(expires) : DateTime.now()),
      createdAt: created is Timestamp
          ? created.toDate()
          : (created is String ? DateTime.parse(created) : DateTime.now()),
      updatedAt: updated is Timestamp
          ? updated.toDate()
          : (updated is String ? DateTime.parse(updated) : DateTime.now()),
    );
  }

  static RequestStatus _parseStatus(String? statusStr) {
    switch (statusStr) {
      case 'viewed':
        return RequestStatus.viewed;
      case 'accepted':
        return RequestStatus.accepted;
      case 'rejected':
        return RequestStatus.rejected;
      case 'expired':
        return RequestStatus.expired;
      case 'cancelledByRequester':
        return RequestStatus.cancelledByRequester;
      case 'negotiating':
        return RequestStatus.negotiating;
      case 'agreementCreated':
        return RequestStatus.agreementCreated;
      case 'sent':
      default:
        return RequestStatus.sent;
    }
  }

  /// Converts this model instance into a domain entity.
  RequestEntity toEntity() {
    return RequestEntity(
      id: id,
      listingId: listingId,
      listingTitle: listingTitle,
      requesterId: requesterId,
      receiverId: receiverId,
      requestType: requestType,
      status: status,
      proposedStartDate: proposedStartDate,
      proposedEndDate: proposedEndDate,
      proposedDurationDays: proposedDurationDays,
      estimatedTotal: estimatedTotal,
      estimatedDeposit: estimatedDeposit,
      message: message,
      expiresAt: expiresAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Converts this model instance to a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'listingId': listingId,
      'listingTitle': listingTitle,
      'requesterId': requesterId,
      'receiverId': receiverId,
      'requestType': requestType.name,
      'status': status.name,
      'proposedStartDate': proposedStartDate.toUtc().toIso8601String(),
      'proposedEndDate': proposedEndDate?.toUtc().toIso8601String(),
      'proposedDurationDays': proposedDurationDays,
      'estimatedTotal': estimatedTotal,
      'estimatedDeposit': estimatedDeposit,
      'message': message,
      'expiresAt': expiresAt.toUtc().toIso8601String(),
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }
}
