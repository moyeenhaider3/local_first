import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:local_first/core/error/exceptions.dart';
import 'package:local_first/core/error/failures.dart';
import 'package:local_first/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:local_first/features/auth/data/models/user_model.dart';
import 'package:local_first/features/auth/domain/entities/user_entity.dart';
import 'package:local_first/features/auth/domain/repositories/auth_repository.dart';

/// AUTH feature - Data Layer: Repository Implementation
/// Concrete implementation of [AuthRepository] backed by the remote datasource,
/// converting local exceptions into domain failures.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, String>> sendOtp(String phone) async {
    try {
      final verificationId = await datasource.sendOtp(phone);
      return Right(verificationId);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> verifyOtp(String verificationId, String smsCode) async {
    try {
      final uid = await datasource.verifyOtp(verificationId, smsCode);
      return Right(uid);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> upsertProfile(String uid, UserEntity entity) async {
    try {
      String? photoUrl = entity.photoUrl;
      if (photoUrl != null && photoUrl.isNotEmpty && !photoUrl.startsWith('http')) {
        final file = File(photoUrl);
        if (await file.exists()) {
          photoUrl = await datasource.uploadProfileAvatar(uid, file);
        }
      }
      final updatedEntity = entity.copyWith(photoUrl: photoUrl);
      await datasource.upsertUserProfile(uid, updatedEntity);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> submitKyc({required String uid, required dynamic imageFile}) async {
    try {
      final url = await datasource.setKycDocument(uid, imageFile);
      await datasource.updateVerificationStatus(uid, 'pending', kycDocumentUrl: url);
      return Right(url);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getUser(String uid) async {
    try {
      final data = await datasource.getUserProfile(uid);
      if (data == null) {
        return const Right(null);
      }
      final model = UserModel.fromJson(data, userId: uid);
      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
