import 'package:dartz/dartz.dart';
import 'package:local_first/core/error/failures.dart';
import 'package:local_first/features/auth/domain/entities/user_entity.dart';

/// AUTH feature - Domain Layer: Repository Contract
/// Abstract interface for authentication, onboarding, and KYC operations.
abstract class AuthRepository {
  /// Sends an SMS OTP to [phone], returning the verificationId.
  Future<Either<Failure, String>> sendOtp(String phone);

  /// Verifies the OTP [smsCode] for [verificationId], returning the UID.
  Future<Either<Failure, String>> verifyOtp(String verificationId, String smsCode);

  /// Creates or merges the user profile document for [uid].
  Future<Either<Failure, void>> upsertProfile(String uid, UserEntity entity);

  /// Uploads a KYC document and flips status to 'pending'. Returns the URL.
  Future<Either<Failure, String>> submitKyc({required String uid, required dynamic imageFile});

  /// Fetches a user document from Firestore (users/{uid}), returning the entity.
  Future<Either<Failure, UserEntity?>> getUser(String uid);

  /// Signs out the active user authentication session.
  Future<Either<Failure, void>> signOut();
}

