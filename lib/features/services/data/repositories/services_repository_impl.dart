import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:local_first/core/error/failures.dart';
import 'package:local_first/features/services/data/datasources/services_remote_datasource.dart';
import 'package:local_first/features/services/data/models/service_profile_model.dart';
import 'package:local_first/features/services/data/models/service_request_model.dart';
import 'package:local_first/features/services/domain/entities/review_entity.dart';
import 'package:local_first/features/services/domain/entities/service_profile_entity.dart';
import 'package:local_first/features/services/domain/entities/service_request_entity.dart';
import 'package:local_first/features/services/domain/entities/worker_availability.dart';
import 'package:local_first/features/services/domain/repositories/services_repository.dart';

/// SERVICES feature - Data Layer: Services Repository Implementation
/// Concrete repository wrapping [ServicesRemoteDatasource] with exception handling and domain conversions.
class ServicesRepositoryImpl implements ServicesRepository {
  /// Remote datasource instance.
  final ServicesRemoteDatasource remoteDatasource;

  /// Creates a [ServicesRepositoryImpl] instance.
  ServicesRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, List<ServiceProfileEntity>>> getWorkersByRadius({
    required GeoPoint center,
    required double radiusKm,
    String? skillFilter,
  }) async {
    try {
      final workers = await remoteDatasource.fetchWorkersByRadius(
        center: center,
        radiusKm: radiusKm,
        skillFilter: skillFilter,
      );
      return Right(workers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ServiceProfileEntity>> getWorkerProfile(String userId) async {
    try {
      final profile = await remoteDatasource.fetchWorkerProfile(userId);
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createServiceProfile(ServiceProfileEntity profile) async {
    try {
      final model = ServiceProfileModel.fromEntity(profile);
      await remoteDatasource.createServiceProfile(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAvailability(String userId, WorkerAvailability status) async {
    try {
      await remoteDatasource.updateAvailability(userId, status);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createServiceRequest(ServiceRequestEntity request) async {
    try {
      final model = ServiceRequestModel.fromEntity(request);
      final requestId = await remoteDatasource.createServiceRequest(model);
      return Right(requestId);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ServiceRequestEntity>>> getInboundJobs(String workerId) async {
    try {
      final jobs = await remoteDatasource.fetchInboundJobs(workerId);
      return Right(jobs);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> acceptServiceRequest(String requestId) async {
    try {
      await remoteDatasource.acceptServiceRequest(requestId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getWorkerReviews(String workerId) async {
    try {
      final reviews = await remoteDatasource.fetchWorkerReviews(workerId);
      return Right(reviews);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
