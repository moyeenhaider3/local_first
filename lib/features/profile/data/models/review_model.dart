import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_first/features/profile/domain/entities/review_entity.dart';

/// PROFILE & REVIEWS feature - Data Layer: Review Model
/// Data model extending [ReviewEntity] with serialization logic for Firestore.
class ReviewModel extends ReviewEntity {
  /// Creates a [ReviewModel] instance.
  const ReviewModel({
    required super.id,
    required super.targetId,
    required super.reviewerId,
    required super.reviewerName,
    required super.rating,
    required super.comment,
    required super.reviewType,
    required super.createdAt,
  });

  /// Factory constructor creating [ReviewModel] from a domain [ReviewEntity].
  factory ReviewModel.fromEntity(ReviewEntity entity) {
    return ReviewModel(
      id: entity.id,
      targetId: entity.targetId,
      reviewerId: entity.reviewerId,
      reviewerName: entity.reviewerName,
      rating: entity.rating,
      comment: entity.comment,
      reviewType: entity.reviewType,
      createdAt: entity.createdAt,
    );
  }

  /// Factory constructor to parse a Firestore DocumentSnapshot into [ReviewModel].
  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final createdRaw = data['createdAt'];
    final DateTime createdDate = createdRaw is Timestamp
        ? createdRaw.toDate()
        : (createdRaw is String ? DateTime.tryParse(createdRaw) ?? DateTime.now() : DateTime.now());

    return ReviewModel(
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

  /// Converts this model into a Firestore map structure for database writes.
  Map<String, dynamic> toMap() {
    return {
      'targetId': targetId,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'rating': rating,
      'comment': comment,
      'reviewType': reviewType,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
