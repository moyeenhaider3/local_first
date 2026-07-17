import 'package:local_first/features/auth/domain/entities/user_entity.dart';

/// AUTH feature - Domain Layer: Repository Contract
/// Abstract interface for authentication, onboarding, and KYC operations.
abstract class AuthRepository {
  /// Sends an SMS OTP to [phone], returning the verificationId.
  Future<String> sendOtp(String phone);

  /// Verifies the OTP [smsCode] for [verificationId], returning the UID.
  Future<String> verifyOtp(String verificationId, String smsCode);

  /// Creates or merges the user profile document for [uid].
  Future<void> upsertProfile(String uid, UserEntity entity);

  /// Uploads a KYC document and flips status to 'pending'. Returns the URL.
  Future<String> submitKyc({required String uid, required dynamic imageFile});
}
