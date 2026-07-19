import 'package:equatable/equatable.dart';

/// Enum representing the type of request (rental vs service).
enum RequestType { rental, service }

/// Enum representing the current status of a booking/service request.
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
///
/// Represents a rental request or service booking request between users in Local First.
class RequestEntity extends Equatable {
  /// Unique document ID of the request.
  final String id;

  /// ID of the listing associated with this request.
  final String listingId;

  /// Human-readable title of the listing.
  final String listingTitle;

  /// UID of the user who submitted the request (renter/client).
  final String requesterId;

  /// UID of the user who receives the request (owner/worker).
  final String receiverId;

  /// Type of request (rental or service).
  final RequestType requestType;

  /// Current status of the request.
  final RequestStatus status;

  /// Proposed start date of the rental or service.
  final DateTime proposedStartDate;

  /// Optional proposed end date for rentals.
  final DateTime? proposedEndDate;

  /// Optional proposed duration in days.
  final int? proposedDurationDays;

  /// Estimated total cost calculated for the proposed dates.
  final double estimatedTotal;

  /// Optional security deposit amount for rental items.
  final double? estimatedDeposit;

  /// Optional message sent by requester to owner/worker.
  final String? message;

  /// Optional reason provided when the request is rejected or auto-declined.
  final String? rejectionReason;

  /// Timestamp when the request expires if unaccepted.
  final DateTime expiresAt;

  /// Timestamp when the request was created.
  final DateTime createdAt;

  /// Timestamp when the request was last updated.
  final DateTime updatedAt;

  /// Creates a [RequestEntity] instance with the specified parameters.
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
    this.rejectionReason,
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
        rejectionReason,
        expiresAt,
        createdAt,
        updatedAt,
      ];
}
