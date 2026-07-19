import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_first/features/profile/domain/entities/review_entity.dart';
import 'package:local_first/features/profile/domain/entities/support_ticket_entity.dart';
import 'package:local_first/features/profile/domain/repositories/profile_repository.dart';
import 'package:local_first/features/profile/presentation/cubits/profile_hub_state.dart';

/// PROFILE feature - Presentation Layer: Profile Hub Cubit
/// Manages state operations for reviews, support tickets, and trust score computations in Local First.
class ProfileHubCubit extends Cubit<ProfileHubState> {
  /// Repository reference.
  final ProfileRepository repository;

  /// Creates a [ProfileHubCubit] instance with initial state.
  ProfileHubCubit({required this.repository}) : super(const ProfileHubInitial());

  /// Loads full profile hub state for [userId] (trust score, reviews, support tickets).
  Future<void> loadProfileData(String userId) async {
    emit(const ProfileHubLoading());

    final scoreResult = await repository.calculateTrustScore(userId);
    final reviewsResult = await repository.fetchUserReviews(userId);
    final ticketsResult = await repository.fetchUserSupportTickets(userId);

    int score = 75; // Default baseline score
    scoreResult.fold(
      (failure) => null,
      (val) => score = val,
    );

    List<ReviewEntity> reviews = [];
    reviewsResult.fold(
      (failure) => null,
      (val) => reviews = val,
    );

    List<SupportTicketEntity> tickets = [];
    ticketsResult.fold(
      (failure) => null,
      (val) => tickets = val,
    );

    emit(ProfileHubLoaded(
      trustScore: score,
      reviews: reviews,
      supportTickets: tickets,
    ));
  }

  /// Submits a review and refreshes profile reviews.
  Future<void> submitReview(ReviewEntity review) async {
    emit(const ProfileHubLoading());
    final result = await repository.submitReview(review);

    result.fold(
      (failure) => emit(ProfileHubError(failure.message)),
      (_) async {
        emit(const ProfileHubActionSuccess('Review submitted successfully.'));
        await loadProfileData(review.targetId);
      },
    );
  }

  /// Creates a support ticket in Local First and updates user ticket list.
  Future<void> createSupportTicket(SupportTicketEntity ticket) async {
    emit(const ProfileHubLoading());
    final result = await repository.createSupportTicket(ticket);

    result.fold(
      (failure) => emit(ProfileHubError(failure.message)),
      (_) async {
        emit(const ProfileHubActionSuccess('Support ticket created successfully.'));
        await loadProfileData(ticket.userId);
      },
    );
  }

  /// Triggers a fresh server-side recalculation of the trust score for [userId].
  Future<void> recalculateTrustScore(String userId) async {
    final result = await repository.calculateTrustScore(userId);

    result.fold(
      (failure) => emit(ProfileHubError(failure.message)),
      (score) {
        if (state is ProfileHubLoaded) {
          emit((state as ProfileHubLoaded).copyWith(trustScore: score));
        } else {
          loadProfileData(userId);
        }
      },
    );
  }
}
