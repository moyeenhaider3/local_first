import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_first/features/services/domain/entities/service_profile_entity.dart';
import 'package:local_first/features/services/domain/entities/service_request_entity.dart';
import 'package:local_first/features/services/domain/entities/worker_availability.dart';
import 'package:local_first/features/services/domain/repositories/services_repository.dart';
import 'package:local_first/features/services/presentation/cubits/services_state.dart';

/// SERVICES feature - Presentation Layer: Services Cubit
/// Business logic component managing worker discovery, profile management, and hire requests.
class ServicesCubit extends Cubit<ServicesState> {
  /// Repository instance.
  final ServicesRepository repository;

  /// Creates a [ServicesCubit] instance.
  ServicesCubit({required this.repository}) : super(const ServicesInitial());

  /// Discovers service workers near a center coordinate within [radiusKm].
  Future<void> fetchWorkersByRadius({
    required GeoPoint center,
    double radiusKm = 10.0,
    String? skillFilter,
  }) async {
    emit(const ServicesLoading());
    final result = await repository.getWorkersByRadius(
      center: center,
      radiusKm: radiusKm,
      skillFilter: skillFilter,
    );

    result.fold(
      (failure) => emit(ServicesError(message: failure.message)),
      (workers) => emit(WorkerListLoaded(workers: workers)),
    );
  }

  /// Fetches details and reviews of a specific worker profile.
  Future<void> fetchWorkerProfile(String userId) async {
    emit(const ServicesLoading());
    final profileResult = await repository.getWorkerProfile(userId);

    await profileResult.fold(
      (failure) async {
        emit(ServicesError(message: failure.message));
      },
      (profile) async {
        final reviewsResult = await repository.getWorkerReviews(userId);
        final reviews = reviewsResult.getOrElse(() => []);
        emit(WorkerProfileLoaded(profile: profile, reviews: reviews));
      },
    );
  }

  /// Registers or updates a service worker profile.
  Future<void> createOrUpdateProfile(ServiceProfileEntity profile) async {
    emit(const ServicesLoading());
    final result = await repository.createServiceProfile(profile);

    result.fold(
      (failure) => emit(ServicesError(message: failure.message)),
      (_) => fetchWorkerProfile(profile.userId),
    );
  }

  /// Toggles worker availability status.
  Future<void> updateAvailability(String userId, WorkerAvailability status) async {
    emit(const ServicesLoading());
    final result = await repository.updateAvailability(userId, status);

    result.fold(
      (failure) => emit(ServicesError(message: failure.message)),
      (_) => emit(AvailabilityUpdated(status: status)),
    );
  }

  /// Sends a hire service request to a worker.
  Future<void> sendServiceRequest(ServiceRequestEntity request) async {
    emit(const ServicesLoading());
    final result = await repository.createServiceRequest(request);

    result.fold(
      (failure) => emit(ServicesError(message: failure.message)),
      (requestId) => emit(ServiceRequestSent(requestId: requestId)),
    );
  }

  /// Retrieves inbound service requests for a worker.
  Future<void> fetchInboundJobs(String workerId) async {
    emit(const ServicesLoading());
    final result = await repository.getInboundJobs(workerId);

    result.fold(
      (failure) => emit(ServicesError(message: failure.message)),
      (jobs) => emit(InboundJobsLoaded(jobs: jobs)),
    );
  }

  /// Accepts an inbound service request.
  Future<void> acceptJobRequest(String requestId, String workerId) async {
    emit(const ServicesLoading());
    final result = await repository.acceptServiceRequest(requestId);

    result.fold(
      (failure) => emit(ServicesError(message: failure.message)),
      (_) => fetchInboundJobs(workerId),
    );
  }
}
