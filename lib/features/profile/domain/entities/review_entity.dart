import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// PROFILE & REVIEWS feature - Domain Layer: Review Entity
/// Represents a user review & rating for rentals or service jobs in Local First.
class ReviewEntity extends Equatable {
  /// Unique review document identifier.
  final String id;

  /// Target user or item ID receiving the review (e.g. workerId or listingId).
  final String targetId;

  /// User ID of the reviewer submitting the rating.
  final String reviewerId;

  /// Display name of the reviewer.
  final String reviewerName;

  /// Rating score given by the reviewer (1.0 to 5.0).
  final double rating;

  /// Review feedback comment text.
  final String comment;

  /// Type of review ('rental' or 'service').
  final String reviewType;

  /// Timestamp when the review was created.
  final DateTime createdAt;

  /// Creates a [ReviewEntity] instance with necessary fields.
  const ReviewEntity({
    required this.id,
    required this.targetId,
    required this.reviewerId,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.reviewType,
    required this.createdAt,
  });

  /// Factory constructor to deserialize from Firestore DocumentSnapshot.
  factory ReviewEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final createdRaw = data['createdAt'];
    final DateTime createdDate = createdRaw is Timestamp
        ? createdRaw.toDate()
        : (createdRaw is String ? DateTime.tryParse(createdRaw) ?? DateTime.now() : DateTime.now());

    return ReviewEntity(
      id: doc.id,
      targetId: data['targetId'] as String? ?? data['workerId'] as String? ?? '',
      reviewerId: data['reviewerId'] as String? ?? '',
      reviewerName: data['reviewerName'] as String? ?? 'Anonymous',
      rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
      comment: data['comment'] as String? ?? '',
      reviewType: data['reviewType'] as String? ?? 'service',
      createdAt: createdDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        targetId,
        reviewerId,
        reviewerName,
        rating,
        comment,
        reviewType,
        createdAt,
      ];
}
