import 'package:dartz/dartz.dart';
import 'package:local_first/core/error/failures.dart';
import 'package:local_first/features/agreements/domain/entities/agreement_entity.dart';
import 'package:local_first/features/agreements/domain/entities/request_entity.dart';
import 'package:local_first/features/agreements/domain/entities/signature_metadata_entity.dart';

abstract class AgreementRepository {
  Future<Either<Failure, String>> createRequest(RequestEntity request);
  Future<Either<Failure, List<RequestEntity>>> getInboundRequests(String receiverId);
  Future<Either<Failure, List<RequestEntity>>> getOutboundRequests(String requesterId);
  Future<Either<Failure, AgreementEntity>> acceptRequest(String requestId);
  Future<Either<Failure, void>> rejectRequest(String requestId, String? reason);
  Future<Either<Failure, AgreementEntity>> getAgreement(String agreementId);
  Future<Either<Failure, List<AgreementEntity>>> getAgreementsByUser(String userId);
  Future<Either<Failure, void>> signAgreement(String agreementId, SignatureMetadataEntity signature);
  Future<Either<Failure, void>> confirmCoordination(String agreementId);
  Stream<AgreementEntity> watchAgreement(String agreementId);
}
