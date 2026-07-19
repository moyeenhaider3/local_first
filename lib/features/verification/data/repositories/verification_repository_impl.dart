import 'package:dartz/dartz.dart';
import 'package:local_first/core/error/failures.dart';
import 'package:local_first/features/verification/data/datasources/verification_remote_datasource.dart';
import 'package:local_first/features/verification/domain/entities/verification_result.dart';
import 'package:local_first/features/verification/domain/entities/verification_task_entity.dart';
import 'package:local_first/features/verification/domain/repositories/verification_repository.dart';

/// Repository implementation for verification operations.
class VerificationRepositoryImpl implements VerificationRepository {
  /// The remote data source wrapper.
  final VerificationRemoteDatasource remoteDatasource;

  /// Creates a [VerificationRepositoryImpl] instance.
  VerificationRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, List<VerificationTaskEntity>>> getTasksForAgreement(String agreementId) async {
    try {
      final tasks = await remoteDatasource.fetchTasksForAgreement(agreementId);
      return Right(tasks);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VerificationTaskEntity>> getTask(String taskId) async {
    try {
      final task = await remoteDatasource.fetchTaskById(taskId);
      return Right(task);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> requestCode(String taskId) async {
    try {
      await remoteDatasource.requestCodeIssuance(taskId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VerificationResult>> verifyCode(String taskId, String plaintextCode) async {
    try {
      final result = await remoteDatasource.submitCode(taskId, plaintextCode);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> getPlaintextCode(String taskId) async {
    try {
      final code = await remoteDatasource.fetchPlaintextCode(taskId);
      return Right(code);
    } catch (e) {
      // Permission denied or other Firebase exceptions are wrapped as Auth or Server failures
      if (e.toString().contains('permission-denied')) {
        return Left(AuthFailure('You do not have access to view this verification code.'));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<VerificationTaskEntity> watchTask(String taskId) {
    return remoteDatasource.listenToTask(taskId);
  }

  @override
  Future<Either<Failure, void>> submitDispute({
    required String agreementId,
    required String disputeType,
    required String description,
    required List<String> photoUrls,
  }) async {
    try {
      await remoteDatasource.submitDispute(
        agreementId: agreementId,
        disputeType: disputeType,
        description: description,
        photoUrls: photoUrls,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadDisputeImages({
    required String agreementId,
    required List<dynamic> imageFiles,
  }) async {
    try {
      final urls = await remoteDatasource.uploadDisputeImages(agreementId, imageFiles);
      return Right(urls);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
