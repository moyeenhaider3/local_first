import 'package:equatable/equatable.dart';
import 'package:local_first/features/services/domain/entities/review_entity.dart';
import 'package:local_first/features/services/domain/entities/service_profile_entity.dart';
import 'package:local_first/features/services/domain/entities/service_request_entity.dart';
import 'package:local_first/features/services/domain/entities/worker_availability.dart';

/// SERVICES feature - Presentation Layer: Services State Hierarchy
/// Sealed state hierarchy representing UI states of the services module.
sealed class ServicesState extends Equatable {
  const ServicesState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
final class ServicesInitial extends ServicesState {
  const ServicesInitial();
}

/// Loading state during async repository actions.
final class ServicesLoading extends ServicesState {
  const ServicesLoading();
}

/// State emitted when worker profile details and reviews are loaded.
final class WorkerProfileLoaded extends ServicesState {
  /// The loaded worker profile.
  final ServiceProfileEntity profile;

  /// Reviews received by this worker.
  final List<ReviewEntity> reviews;

  /// Creates a [WorkerProfileLoaded] state.
  const WorkerProfileLoaded({
    required this.profile,
    this.reviews = const [],
  });

  @override
  List<Object?> get props => [profile, reviews];
}

/// State emitted when worker search results are loaded.
final class WorkerListLoaded extends ServicesState {
  /// List of matching service worker profiles.
  final List<ServiceProfileEntity> workers;

  /// Creates a [WorkerListLoaded] state.
  const WorkerListLoaded({required this.workers});

  @override
  List<Object?> get props => [workers];
}

/// State emitted when availability status is successfully updated.
final class AvailabilityUpdated extends ServicesState {
  /// The updated availability status.
  final WorkerAvailability status;

  /// Creates an [AvailabilityUpdated] state.
  const AvailabilityUpdated({required this.status});

  @override
  List<Object?> get props => [status];
}

/// State emitted when a service request is successfully created and sent.
final class ServiceRequestSent extends ServicesState {
  /// Created service request ID.
  final String requestId;

  /// Creates a [ServiceRequestSent] state.
  const ServiceRequestSent({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}

/// State emitted when inbound job requests for a worker are loaded.
final class InboundJobsLoaded extends ServicesState {
  /// Inbound service requests.
  final List<ServiceRequestEntity> jobs;

  /// Creates an [InboundJobsLoaded] state.
  const InboundJobsLoaded({required this.jobs});

  @override
  List<Object?> get props => [jobs];
}

/// Error state emitted on failure.
final class ServicesError extends ServicesState {
  /// Human-readable error message.
  final String message;

  /// Creates a [ServicesError] state.
  const ServicesError({required this.message});

  @override
  List<Object?> get props => [message];
}
