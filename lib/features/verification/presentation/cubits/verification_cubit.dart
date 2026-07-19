import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_first/features/verification/domain/entities/verification_task_entity.dart';
import 'package:local_first/features/verification/domain/repositories/verification_repository.dart';
import 'package:local_first/features/verification/presentation/cubits/verification_state.dart';

/// Cubit managing the business logic and UI states for milestone code verification in the Local First app.
class VerificationCubit extends Cubit<VerificationState> {
  /// Repository for verification operations.
  final VerificationRepository _repository;

  /// Stream subscription to real-time verification task updates.
  StreamSubscription<VerificationTaskEntity>? _taskSubscription;

  /// Creates a [VerificationCubit] with dependency injection.
  VerificationCubit(this._repository) : super(const VerificationInitial());

  /// Subscribes to real-time updates for a verification task.
  void watchTask(String taskId) {
    emit(const VerificationLoading());
    _taskSubscription?.cancel();
    _taskSubscription = _repository.watchTask(taskId).listen(
      (task) {
        final now = DateTime.now();
        if (task.status == VerificationStatus.verified) {
          emit(CodeVerificationSuccess(task: task));
        } else if (task.status == VerificationStatus.rejected || task.attemptsUsed >= task.maxAttempts) {
          emit(const CodeVerificationFailure(
            attemptsRemaining: 0,
            message: 'Verification task rejected due to too many failed attempts.',
          ));
        } else if (task.status == VerificationStatus.expired || now.isAfter(task.expiresAt)) {
          emit(const TaskExpired());
        } else if (task.status == VerificationStatus.initiatorConfirmed) {
          // If code is issued, fetch plaintext code (only works if user is the code-holder).
          _fetchPlaintextCode(taskId);
        } else if (task.status == VerificationStatus.pending) {
          emit(const VerificationInitial());
        }
      },
      onError: (error) {
        emit(VerificationError(message: error.toString()));
      },
    );
  }

  /// Helper to fetch the plaintext code. Only succeeds if the current user has read access.
  Future<void> _fetchPlaintextCode(String taskId) async {
    final result = await _repository.getPlaintextCode(taskId);
    result.fold(
      (failure) {
        // If permission denied, the user is likely the verifier, not the code holder.
        // We emit CodeIssued with null code so the UI knows code has been generated.
        emit(const CodeIssued(plaintextCode: null));
      },
      (code) {
        emit(CodeIssued(plaintextCode: code));
      },
    );
  }

  /// Requests the issuance of a new milestone code for the task.
  Future<void> requestCode(String taskId) async {
    emit(const VerificationLoading());
    final result = await _repository.requestCode(taskId);
    result.fold(
      (failure) => emit(VerificationError(message: failure.message)),
      (_) {
        // Code request sent successfully.
        // We do not emit state directly; the watchTask stream listener will update the status
        // to initiatorConfirmed and trigger _fetchPlaintextCode.
      },
    );
  }

  /// Submits the plaintext code for server-side verification.
  Future<void> submitVerificationCode(String taskId, String code) async {
    emit(const CodeSubmitting());
    final result = await _repository.verifyCode(taskId, code);
    result.fold(
      (failure) => emit(VerificationError(message: failure.message)),
      (verificationResult) {
        if (verificationResult.verified) {
          // Fetch the latest task to get updated timestamps/status.
          _repository.getTask(taskId).then((taskResult) {
            taskResult.fold(
              (failure) => emit(VerificationError(message: failure.message)),
              (task) => emit(CodeVerificationSuccess(task: task)),
            );
          });
        } else {
          emit(CodeVerificationFailure(
            attemptsRemaining: verificationResult.attemptsRemaining,
            message: verificationResult.message,
          ));
        }
      },
    );
  }

  @override
  Future<void> close() {
    _taskSubscription?.cancel();
    return super.close();
  }

  /// Submits a damage dispute with photo uploads, emitting [DisputeSubmitting] and [DisputeSuccess].
  Future<void> submitDispute({
    required String agreementId,
    required String disputeType,
    required String description,
    required List<dynamic> imageFiles,
  }) async {
    emit(const DisputeSubmitting());
    
    // First, upload images if there are any.
    List<String> photoUrls = [];
    if (imageFiles.isNotEmpty) {
      final uploadResult = await _repository.uploadDisputeImages(
        agreementId: agreementId,
        imageFiles: imageFiles,
      );
      
      bool uploadFailed = false;
      uploadResult.fold(
        (failure) {
          uploadFailed = true;
          emit(VerificationError(message: failure.message));
        },
        (urls) {
          photoUrls = urls;
        },
      );
      if (uploadFailed) return;
    }
    
    // Then submit dispute details.
    final disputeResult = await _repository.submitDispute(
      agreementId: agreementId,
      disputeType: disputeType,
      description: description,
      photoUrls: photoUrls,
    );
    
    disputeResult.fold(
      (failure) => emit(VerificationError(message: failure.message)),
      (_) => emit(const DisputeSuccess()),
    );
  }
}
