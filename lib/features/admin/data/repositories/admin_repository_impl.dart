import 'package:dartz/dartz.dart';
import 'package:local_first/core/error/exceptions.dart';
import 'package:local_first/core/error/failures.dart';
import 'package:local_first/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:local_first/features/admin/domain/repositories/admin_repository.dart';
import 'package:local_first/features/auth/data/models/user_model.dart';
import 'package:local_first/features/auth/domain/entities/user_entity.dart';

/// ADMIN feature - Data Layer: Repository Implementation
class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDatasource remoteDatasource;

  AdminRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, List<UserEntity>>> getPendingKycUsers() async {
    try {
      final list = await remoteDatasource.getPendingKycUsers();
      final users = list.map((docMap) {
        final userId = docMap['userId'] as String;
        return UserModel.fromJson(docMap, userId: userId).toEntity();
      }).toList();
      return Right(users);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateKycStatus(
    String uid,
    String status,
    String? remarks,
  ) async {
    try {
      await remoteDatasource.updateKycStatus(uid, status, remarks);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getAdminUsers() async {
    try {
      final list = await remoteDatasource.getAdminUsers();
      final users = list.map((docMap) {
        final userId = docMap['userId'] as String;
        return UserModel.fromJson(docMap, userId: userId).toEntity();
      }).toList();
      return Right(users);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> searchUsers(String query) async {
    try {
      final list = await remoteDatasource.searchUsers(query);
      final users = list.map((docMap) {
        final userId = docMap['userId'] as String;
        return UserModel.fromJson(docMap, userId: userId).toEntity();
      }).toList();
      return Right(users);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setAdminRole(String uid, String? role) async {
    try {
      await remoteDatasource.setAdminRole(uid, role);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
