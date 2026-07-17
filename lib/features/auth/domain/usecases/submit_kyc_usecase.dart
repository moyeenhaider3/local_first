import 'package:local_first/features/auth/domain/repositories/auth_repository.dart';

/// AUTH feature - Domain Layer: Submit KYC UseCase
/// Encapsulates the business rule for submitting KYC documents for verification.
class SubmitKycUsecase {
  final AuthRepository repository;

  SubmitKycUsecase(this.repository);

  /// Uploads the KYC document for [uid] and sets verificationStatus to
  /// 'pending' (never 'verified' — that is reserved for admin/Cloud Functions).
  /// Returns the uploaded document URL.
  Future<String> call({required String uid, required dynamic imageFile}) {
    return repository.submitKyc(uid: uid, imageFile: imageFile);
  }
}
