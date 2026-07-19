import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:local_first/features/verification/data/models/verification_task_model.dart';
import 'package:local_first/features/verification/domain/entities/verification_result.dart';
import 'package:local_first/features/verification/domain/entities/verification_task_entity.dart';

/// Interface for the remote data source of the verification feature.
abstract class VerificationRemoteDatasource {
  /// Fetches verification tasks associated with a specific agreement ID.
  Future<List<VerificationTaskEntity>> fetchTasksForAgreement(String agreementId);

  /// Fetches a specific verification task by its unique ID.
  Future<VerificationTaskEntity> fetchTaskById(String taskId);

  /// Requests the issuance of a milestone code via a Cloud Function.
  Future<void> requestCodeIssuance(String taskId);

  /// Submits a plaintext code to the Cloud Function for verification.
  Future<VerificationResult> submitCode(String taskId, String plaintextCode);

  /// Fetches the plaintext code directly from Firestore, if read access is permitted.
  Future<String?> fetchPlaintextCode(String taskId);

  /// Establishes a real-time stream listener for updates on a specific task.
  Stream<VerificationTaskEntity> listenToTask(String taskId);

  /// Submits a damage dispute to the Cloud Function.
  Future<void> submitDispute({
    required String agreementId,
    required String disputeType,
    required String description,
    required List<String> photoUrls,
  });

  /// Uploads dispute evidence photo files to Firebase Storage.
  Future<List<String>> uploadDisputeImages(String agreementId, List<dynamic> imageFiles);
}

/// Remote data source implementation using Firebase Firestore and Cloud Functions.
class VerificationRemoteDatasourceImpl implements VerificationRemoteDatasource {
  /// The Firestore instance used for queries.
  final FirebaseFirestore firestore;

  /// The Cloud Functions instance used for RPC calls.
  final FirebaseFunctions functions;

  /// The Firebase Storage instance used for uploads.
  final FirebaseStorage storage;

  /// Creates a [VerificationRemoteDatasourceImpl] instance.
  VerificationRemoteDatasourceImpl({
    required this.firestore,
    required this.functions,
    required this.storage,
  });

  @override
  Future<List<VerificationTaskEntity>> fetchTasksForAgreement(String agreementId) async {
    final querySnapshot = await firestore
        .collection('verification_tasks')
        .where('agreementId', isEqualTo: agreementId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => VerificationTaskModel.fromJson(doc.data(), id: doc.id).toEntity())
        .toList();
  }

  @override
  Future<VerificationTaskEntity> fetchTaskById(String taskId) async {
    final docSnapshot = await firestore.collection('verification_tasks').doc(taskId).get();
    if (!docSnapshot.exists || docSnapshot.data() == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Verification task not found: $taskId',
      );
    }
    return VerificationTaskModel.fromJson(docSnapshot.data()!, id: docSnapshot.id).toEntity();
  }

  @override
  Future<void> requestCodeIssuance(String taskId) async {
    await functions
        .httpsCallable('issueMilestoneCode')
        .call({'taskId': taskId});
  }

  @override
  Future<VerificationResult> submitCode(String taskId, String plaintextCode) async {
    final result = await functions
        .httpsCallable('consumeMilestoneCode')
        .call({
          'taskId': taskId,
          'code': plaintextCode,
        });

    final data = result.data;
    if (data is Map) {
      final verified = data['verified'] as bool? ?? false;
      final attemptsRemaining = data['attemptsRemaining'] as int? ?? 0;
      final message = data['message'] as String? ?? '';
      return VerificationResult(
        verified: verified,
        attemptsRemaining: attemptsRemaining,
        message: message,
      );
    }

    throw FirebaseFunctionsException(
      message: 'Invalid response from consumeMilestoneCode Cloud Function',
      code: 'invalid-argument',
      details: data,
    );
  }

  @override
  Future<String?> fetchPlaintextCode(String taskId) async {
    final docSnapshot = await firestore.collection('milestone_codes').doc(taskId).get();
    if (docSnapshot.exists && docSnapshot.data() != null) {
      return docSnapshot.data()!['code'] as String?;
    }
    return null;
  }

  @override
  Stream<VerificationTaskEntity> listenToTask(String taskId) {
    return firestore
        .collection('verification_tasks')
        .doc(taskId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) {
            throw FirebaseException(
              plugin: 'cloud_firestore',
              message: 'Verification task not found: $taskId',
            );
          }
          return VerificationTaskModel.fromJson(snapshot.data()!, id: snapshot.id).toEntity();
        });
  }

  @override
  Future<void> submitDispute({
    required String agreementId,
    required String disputeType,
    required String description,
    required List<String> photoUrls,
  }) async {
    await functions.httpsCallable('createDamageDispute').call({
      'agreementId': agreementId,
      'disputeType': disputeType,
      'description': description,
      'photoUrls': photoUrls,
    });
  }

  @override
  Future<List<String>> uploadDisputeImages(
    String agreementId,
    List<dynamic> imageFiles,
  ) async {
    try {
      final List<String> downloadUrls = [];
      for (int i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];
        final ref = storage.ref().child('disputes/$agreementId/$i.jpg');
        final uploadTask = ref.putData(
          await file.readAsBytes(),
          SettableMetadata(contentType: 'image/jpeg'),
        );
        final snapshot = await uploadTask;
        final url = await snapshot.ref.getDownloadURL();
        downloadUrls.add(url);
      }
      return downloadUrls;
    } catch (e) {
      throw FirebaseException(
        plugin: 'firebase_storage',
        code: 'upload-error',
        message: e.toString(),
      );
    }
  }
}
