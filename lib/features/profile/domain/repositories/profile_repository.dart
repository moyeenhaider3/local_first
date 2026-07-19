import 'package:dartz/dartz.dart';
import 'package:local_first/core/error/failures.dart';
import 'package:local_first/features/profile/domain/entities/review_entity.dart';
import 'package:local_first/features/profile/domain/entities/support_ticket_entity.dart';

/// PROFILE feature - Domain Layer: Profile Repository Interface
/// Contract defining profile, reviews, support tickets, and trust score computations.
abstract class ProfileRepository {
  /// Submits a review and rating for a user or service job in Local First.
  Future<Either<Failure, void>> submitReview(ReviewEntity review);

  /// Retrieves all reviews for a specified target user/item.
  Future<Either<Failure, List<ReviewEntity>>> fetchUserReviews(String targetId);

  /// Creates a new support ticket in Local First.
  Future<Either<Failure, void>> createSupportTicket(SupportTicketEntity ticket);

  /// Fetches all support tickets created by a specific user.
  Future<Either<Failure, List<SupportTicketEntity>>> fetchUserSupportTickets(String userId);

  /// Requests a server-side trust score calculation for a user.
  Future<Either<Failure, int>> calculateTrustScore(String userId);
}
