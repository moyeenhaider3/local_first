import 'package:dartz/dartz.dart';
import 'package:local_first/core/error/failures.dart';
import 'package:local_first/features/agreements/data/datasources/agreement_remote_datasource.dart';
import 'package:local_first/features/agreements/data/models/request_model.dart';
import 'package:local_first/features/agreements/domain/entities/agreement_entity.dart';
import 'package:local_first/features/agreements/domain/entities/request_entity.dart';
import 'package:local_first/features/agreements/domain/entities/signature_metadata_entity.dart';
import 'package:local_first/features/agreements/domain/repositories/agreement_repository.dart';

class AgreementRepositoryImpl implements AgreementRepository {
  final AgreementRemoteDatasource remoteDatasource;

  AgreementRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, String>> createRequest(RequestEntity request) async {
    try {
      // Prevent requesting your own listing on the client before calling the Cloud Function.
      if (request.requesterId == request.receiverId) {
        return Left(ValidationFailure('You cannot request your own listing.'));
      }
      final model = RequestModel.fromEntity(request);
      final requestId = await remoteDatasource.createRequest(model);
      return Right(requestId);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RequestEntity>>> getInboundRequests(
    String receiverId,
  ) async {
    try {
      final requests = await remoteDatasource.fetchInboundRequests(receiverId);
      return Right(requests);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RequestEntity>>> getOutboundRequests(
    String requesterId,
  ) async {
    try {
      final requests = await remoteDatasource.fetchOutboundRequests(
        requesterId,
      );
      return Right(requests);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AgreementEntity>> acceptRequest(
    String requestId,
  ) async {
    try {
      final agreement = await remoteDatasource.acceptRequest(requestId);
      return Right(agreement);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectRequest(
    String requestId,
    String? reason,
  ) async {
    try {
      await remoteDatasource.rejectRequest(requestId, reason);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AgreementEntity>> getAgreement(
    String agreementId,
  ) async {
    try {
      final agreement = await remoteDatasource.fetchAgreement(agreementId);
      return Right(agreement);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AgreementEntity>>> getAgreementsByUser(
    String userId,
  ) async {
    try {
      final agreements = await remoteDatasource.fetchAgreementsByUser(userId);
      return Right(agreements);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signAgreement(
    String agreementId,
    SignatureMetadataEntity signature,
  ) async {
    try {
      await remoteDatasource.signAgreement(agreementId, signature);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> confirmCoordination(String agreementId) async {
    try {
      await remoteDatasource.confirmCoordination(agreementId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<AgreementEntity> watchAgreement(String agreementId) {
    return remoteDatasource.listenToAgreement(agreementId);
  }
}
