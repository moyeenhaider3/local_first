import 'package:dartz/dartz.dart';
import 'package:local_first/core/error/failures.dart';
import 'package:local_first/features/auth/domain/entities/user_entity.dart';

/// ADMIN feature - Domain Layer: Repository Interface
abstract class AdminRepository {
  Future<Either<Failure, List<UserEntity>>> getPendingKycUsers();
  Future<Either<Failure, void>> updateKycStatus(String uid, String status, String? remarks);
  Future<Either<Failure, List<UserEntity>>> getAdminUsers();
  Future<Either<Failure, List<UserEntity>>> searchUsers(String query);
  Future<Either<Failure, void>> setAdminRole(String uid, String? role);
}
