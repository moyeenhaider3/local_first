import 'package:dartz/dartz.dart';
import 'package:local_first/core/error/failures.dart';
import 'package:local_first/features/verification/domain/entities/verification_result.dart';
import 'package:local_first/features/verification/domain/entities/verification_task_entity.dart';

/// Repository interface for code verification operations in the Local First app.
abstract class VerificationRepository {
  /// Retrieves a list of verification tasks associated with an agreement.
  Future<Either<Failure, List<VerificationTaskEntity>>> getTasksForAgreement(String agreementId);

  /// Retrieves a verification task by its ID.
  Future<Either<Failure, VerificationTaskEntity>> getTask(String taskId);

  /// Requests generation/issuance of a code for a task.
  Future<Either<Failure, void>> requestCode(String taskId);

  /// Submits the plaintext code for verification.
  Future<Either<Failure, VerificationResult>> verifyCode(String taskId, String plaintextCode);

  /// Fetches the plaintext code if the caller is authorized to view it.
  Future<Either<Failure, String?>> getPlaintextCode(String taskId);

  /// Establishes a stream of a specific verification task for real-time updates.
  Stream<VerificationTaskEntity> watchTask(String taskId);

  /// Submits a damage dispute for an agreement with descriptive text and photo URLs.
  Future<Either<Failure, void>> submitDispute({
    required String agreementId,
    required String disputeType,
    required String description,
    required List<String> photoUrls,
  });

  /// Uploads damage dispute photo files to Firebase Storage and returns their download URLs.
  Future<Either<Failure, List<String>>> uploadDisputeImages({
    required String agreementId,
    required List<dynamic> imageFiles,
  });
}
