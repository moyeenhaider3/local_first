import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// SERVICES feature - Domain Layer: Review Entity
/// Business entity representing a worker review & rating in Local First.
class ReviewEntity extends Equatable {
  /// Review unique document ID.
  final String id;

  /// Worker user ID receiving the review.
  final String workerId;

  /// Reviewer user ID (customer).
  final String reviewerId;

  /// Display name of the reviewer.
  final String reviewerName;

  /// Rating score (1.0 to 5.0).
  final double rating;

  /// Review feedback comment text.
  final String comment;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Creates a [ReviewEntity] instance.
  const ReviewEntity({
    required this.id,
    required this.workerId,
    required this.reviewerId,
    required this.reviewerName,
    required this.rating,
    required this.comment,
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
      workerId: data['workerId'] as String? ?? '',
      reviewerId: data['reviewerId'] as String? ?? '',
      reviewerName: data['reviewerName'] as String? ?? 'Anonymous',
      rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
      comment: data['comment'] as String? ?? '',
      createdAt: createdDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workerId,
        reviewerId,
        reviewerName,
        rating,
        comment,
        createdAt,
      ];
}
