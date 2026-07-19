import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:local_first/core/error/failures.dart';
import 'package:local_first/features/services/domain/entities/review_entity.dart';
import 'package:local_first/features/services/domain/entities/service_profile_entity.dart';
import 'package:local_first/features/services/domain/entities/service_request_entity.dart';
import 'package:local_first/features/services/domain/entities/worker_availability.dart';

/// SERVICES feature - Domain Layer: Services Repository Contract
/// Defines high-level operations for discovering workers, creating hire requests, and updating availability.
abstract class ServicesRepository {
  /// Discovers service workers near a center location within radiusKm.
  Future<Either<Failure, List<ServiceProfileEntity>>> getWorkersByRadius({
    required GeoPoint center,
    required double radiusKm,
    String? skillFilter,
  });

  /// Retrieves a specific worker profile.
  Future<Either<Failure, ServiceProfileEntity>> getWorkerProfile(String userId);

  /// Registers or updates a service profile.
  Future<Either<Failure, void>> createServiceProfile(ServiceProfileEntity profile);

  /// Updates worker availability status.
  Future<Either<Failure, void>> updateAvailability(String userId, WorkerAvailability status);

  /// Submits a hire service request.
  Future<Either<Failure, String>> createServiceRequest(ServiceRequestEntity request);

  /// Retrieves inbound service requests for a worker.
  Future<Either<Failure, List<ServiceRequestEntity>>> getInboundJobs(String workerId);

  /// Accepts a service request.
  Future<Either<Failure, void>> acceptServiceRequest(String requestId);

  /// Retrieves user reviews for a worker.
  Future<Either<Failure, List<ReviewEntity>>> getWorkerReviews(String workerId);
}
