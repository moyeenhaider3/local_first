import 'package:equatable/equatable.dart';
import 'package:local_first/features/profile/domain/entities/review_entity.dart';
import 'package:local_first/features/profile/domain/entities/support_ticket_entity.dart';

/// PROFILE feature - Presentation Layer: Profile Hub State
/// Base abstract state class for profile operations.
abstract class ProfileHubState extends Equatable {
  /// Base constructor.
  const ProfileHubState();

  @override
  List<Object?> get props => [];
}

/// Initial state when profile hub is initialized.
class ProfileHubInitial extends ProfileHubState {
  /// Creates a [ProfileHubInitial] instance.
  const ProfileHubInitial();
}

/// Loading state during profile asynchronous queries or operations.
class ProfileHubLoading extends ProfileHubState {
  /// Creates a [ProfileHubLoading] instance.
  const ProfileHubLoading();
}

/// State holding loaded profile data including trust score, reviews feed, and support tickets.
class ProfileHubLoaded extends ProfileHubState {
  /// Calculated server-side trust score out of 100.
  final int trustScore;

  /// List of reviews for the user/worker profile.
  final List<ReviewEntity> reviews;

  /// List of support tickets filed by the user.
  final List<SupportTicketEntity> supportTickets;

  /// Creates a [ProfileHubLoaded] state instance.
  const ProfileHubLoaded({
    required this.trustScore,
    required this.reviews,
    required this.supportTickets,
  });

  /// Creates a copy of [ProfileHubLoaded] with updated optional parameters.
  ProfileHubLoaded copyWith({
    int? trustScore,
    List<ReviewEntity>? reviews,
    List<SupportTicketEntity>? supportTickets,
  }) {
    return ProfileHubLoaded(
      trustScore: trustScore ?? this.trustScore,
      reviews: reviews ?? this.reviews,
      supportTickets: supportTickets ?? this.supportTickets,
    );
  }

  @override
  List<Object?> get props => [trustScore, reviews, supportTickets];
}

/// Error state when a profile operation fails.
class ProfileHubError extends ProfileHubState {
  /// User-friendly error message description.
  final String message;

  /// Creates a [ProfileHubError] instance.
  const ProfileHubError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Transient success state for write actions such as review submission or ticket creation.
class ProfileHubActionSuccess extends ProfileHubState {
  /// Success notification message.
  final String message;

  /// Creates a [ProfileHubActionSuccess] instance.
  const ProfileHubActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
