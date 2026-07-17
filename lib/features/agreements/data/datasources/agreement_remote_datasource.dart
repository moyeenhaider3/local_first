import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:local_first/features/agreements/data/models/agreement_model.dart';
import 'package:local_first/features/agreements/data/models/request_model.dart';
import 'package:local_first/features/agreements/domain/entities/agreement_entity.dart';
import 'package:local_first/features/agreements/domain/entities/request_entity.dart';
import 'package:local_first/features/agreements/domain/entities/signature_metadata_entity.dart';

abstract class AgreementRemoteDatasource {
  Future<String> createRequest(RequestModel request);
  Future<List<RequestEntity>> fetchInboundRequests(String receiverId);
  Future<List<RequestEntity>> fetchOutboundRequests(String requesterId);
  Future<AgreementEntity> acceptRequest(String requestId);
  Future<void> rejectRequest(String requestId, String? reason);
  Future<AgreementEntity> fetchAgreement(String agreementId);
  Future<List<AgreementEntity>> fetchAgreementsByUser(String userId);
  Future<void> signAgreement(String agreementId, SignatureMetadataEntity signature);
  Stream<AgreementEntity> listenToAgreement(String agreementId);
}

class AgreementRemoteDatasourceImpl implements AgreementRemoteDatasource {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  AgreementRemoteDatasourceImpl({
    required this.firestore,
    required this.functions,
  });

  @override
  Future<String> createRequest(RequestModel request) async {
    final result = await functions
        .httpsCallable('createRequest')
        .call(request.toJson());
    
    final data = result.data;
    if (data is Map && data.containsKey('requestId')) {
      return data['requestId'] as String;
    } else if (data is String) {
      return data;
    }
    throw FirebaseFunctionsException(
      message: 'Invalid response from createRequest Cloud Function',
      code: 'invalid-argument',
      details: data,
    );
  }

  @override
  Future<List<RequestEntity>> fetchInboundRequests(String receiverId) async {
    final querySnapshot = await firestore
        .collection('requests')
        .where('receiverId', isEqualTo: receiverId)
        .where('status', whereIn: ['sent', 'viewed'])
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => RequestModel.fromJson(doc.data(), id: doc.id).toEntity())
        .toList();
  }

  @override
  Future<List<RequestEntity>> fetchOutboundRequests(String requesterId) async {
    final querySnapshot = await firestore
        .collection('requests')
        .where('requesterId', isEqualTo: requesterId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => RequestModel.fromJson(doc.data(), id: doc.id).toEntity())
        .toList();
  }

  @override
  Future<AgreementEntity> acceptRequest(String requestId) async {
    final result = await functions
        .httpsCallable('acceptRequest')
        .call({'requestId': requestId});

    final data = result.data;
    String? agreementId;
    
    if (data is Map) {
      if (data.containsKey('agreementId')) {
        agreementId = data['agreementId'] as String;
      } else if (data.containsKey('id')) {
        return AgreementModel.fromJson(Map<String, dynamic>.from(data), id: data['id'] as String).toEntity();
      }
    } else if (data is String) {
      agreementId = data;
    }

    if (agreementId != null) {
      return await fetchAgreement(agreementId);
    }

    throw FirebaseFunctionsException(
      message: 'Invalid response from acceptRequest Cloud Function',
      code: 'invalid-argument',
      details: data,
    );
  }

  @override
  Future<void> rejectRequest(String requestId, String? reason) async {
    await functions
        .httpsCallable('rejectRequest')
        .call({
          'requestId': requestId,
          'reason': reason,
        });
  }

  @override
  Future<AgreementEntity> fetchAgreement(String agreementId) async {
    final docSnapshot = await firestore.collection('agreements').doc(agreementId).get();
    if (!docSnapshot.exists || docSnapshot.data() == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Agreement not found: $agreementId',
      );
    }
    return AgreementModel.fromJson(docSnapshot.data()!, id: docSnapshot.id).toEntity();
  }

  @override
  Future<List<AgreementEntity>> fetchAgreementsByUser(String userId) async {
    // Querying where user is initiator
    final initiatorQuery = await firestore
        .collection('agreements')
        .where('initiatorId', isEqualTo: userId)
        .get();

    // Querying where user is counterparty
    final counterpartyQuery = await firestore
        .collection('agreements')
        .where('counterpartyId', isEqualTo: userId)
        .get();

    final Set<AgreementEntity> agreements = {};

    for (final doc in initiatorQuery.docs) {
      agreements.add(AgreementModel.fromJson(doc.data(), id: doc.id).toEntity());
    }
    for (final doc in counterpartyQuery.docs) {
      agreements.add(AgreementModel.fromJson(doc.data(), id: doc.id).toEntity());
    }

    final sortedList = agreements.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return sortedList;
  }

  @override
  Future<void> signAgreement(String agreementId, SignatureMetadataEntity signature) async {
    await functions
        .httpsCallable('recordAgreementConsent')
        .call({
          'agreementId': agreementId,
          'signature': signature.toJson(),
        });
  }

  @override
  Stream<AgreementEntity> listenToAgreement(String agreementId) {
    return firestore
        .collection('agreements')
        .doc(agreementId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) {
            throw FirebaseException(
              plugin: 'cloud_firestore',
              message: 'Agreement not found: $agreementId',
            );
          }
          return AgreementModel.fromJson(snapshot.data()!, id: snapshot.id).toEntity();
        });
  }
}
