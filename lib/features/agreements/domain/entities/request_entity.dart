import 'package:equatable/equatable.dart';

enum RequestType { rental, service }

enum RequestStatus {
  sent,
  viewed,
  accepted,
  rejected,
  expired,
  cancelledByRequester,
  negotiating,
  agreementCreated
}

/// Domain Layer: Request Entity
/// Represents a rental request or service booking request between users.
class RequestEntity extends Equatable {
  final String id;
  final String listingId;
  final String listingTitle;
  final String requesterId;
  final String receiverId;
  final RequestType requestType;
  final RequestStatus status;
  final DateTime proposedStartDate;
  final DateTime? proposedEndDate;
  final int? proposedDurationDays;
  final double estimatedTotal;
  final double? estimatedDeposit;
  final String? message;
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RequestEntity({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.requesterId,
    required this.receiverId,
    required this.requestType,
    required this.status,
    required this.proposedStartDate,
    this.proposedEndDate,
    this.proposedDurationDays,
    required this.estimatedTotal,
    this.estimatedDeposit,
    this.message,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        listingId,
        listingTitle,
        requesterId,
        receiverId,
        requestType,
        status,
        proposedStartDate,
        proposedEndDate,
        proposedDurationDays,
        estimatedTotal,
        estimatedDeposit,
        message,
        expiresAt,
        createdAt,
        updatedAt,
      ];
}
