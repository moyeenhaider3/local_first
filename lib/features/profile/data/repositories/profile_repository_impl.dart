import 'package:dartz/dartz.dart';
import 'package:local_first/core/error/failures.dart';
import 'package:local_first/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:local_first/features/profile/data/models/review_model.dart';
import 'package:local_first/features/profile/data/models/support_ticket_model.dart';
import 'package:local_first/features/profile/domain/entities/review_entity.dart';
import 'package:local_first/features/profile/domain/entities/support_ticket_entity.dart';
import 'package:local_first/features/profile/domain/repositories/profile_repository.dart';

/// PROFILE feature - Data Layer: Profile Repository Implementation
/// Concrete implementation wrapping [ProfileRemoteDatasource] with exception mapping.
class ProfileRepositoryImpl implements ProfileRepository {
  /// Remote datasource instance.
  final ProfileRemoteDatasource remoteDatasource;

  /// Creates a [ProfileRepositoryImpl] instance.
  ProfileRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, void>> submitReview(ReviewEntity review) async {
    try {
      final model = ReviewModel.fromEntity(review);
      await remoteDatasource.submitReview(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> fetchUserReviews(String targetId) async {
    try {
      final reviews = await remoteDatasource.fetchUserReviews(targetId);
      return Right(reviews);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createSupportTicket(SupportTicketEntity ticket) async {
    try {
      final model = SupportTicketModel.fromEntity(ticket);
      await remoteDatasource.createSupportTicket(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SupportTicketEntity>>> fetchUserSupportTickets(String userId) async {
    try {
      final tickets = await remoteDatasource.fetchUserSupportTickets(userId);
      return Right(tickets);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> calculateTrustScore(String userId) async {
    try {
      final score = await remoteDatasource.calculateTrustScore(userId);
      return Right(score);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
