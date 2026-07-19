import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:local_first/features/services/data/models/service_profile_model.dart';
import 'package:local_first/features/services/data/models/service_request_model.dart';
import 'package:local_first/features/services/domain/entities/review_entity.dart';
import 'package:local_first/features/services/domain/entities/service_profile_entity.dart';
import 'package:local_first/features/services/domain/entities/service_request_entity.dart';
import 'package:local_first/features/services/domain/entities/worker_availability.dart';

/// SERVICES feature - Data Layer: Services Remote Datasource
/// Contract for remote operations against Firestore and Cloud Functions for service worker discovery & hiring.
abstract class ServicesRemoteDatasource {
  /// Fetches service workers within a given radius (in km) from a center coordinate.
  Future<List<ServiceProfileEntity>> fetchWorkersByRadius({
    required GeoPoint center,
    required double radiusKm,
    String? skillFilter,
  });

  /// Fetches a specific worker profile by user ID.
  Future<ServiceProfileEntity> fetchWorkerProfile(String userId);

  /// Creates or updates a service worker profile in profiles/{userId}.
  Future<void> createServiceProfile(ServiceProfileModel profile);

  /// Updates a worker's availability status.
  Future<void> updateAvailability(String userId, WorkerAvailability status);

  /// Submits a new hire request to a service worker.
  Future<String> createServiceRequest(ServiceRequestModel request);

  /// Fetches all inbound job requests for a worker.
  Future<List<ServiceRequestEntity>> fetchInboundJobs(String workerId);

  /// Accepts an inbound service request.
  Future<void> acceptServiceRequest(String requestId);

  /// Fetches user reviews for a specific worker.
  Future<List<ReviewEntity>> fetchWorkerReviews(String workerId);
}

/// Implementation of [ServicesRemoteDatasource] using [FirebaseFirestore] and [FirebaseFunctions].
class ServicesRemoteDatasourceImpl implements ServicesRemoteDatasource {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  /// Creates a [ServicesRemoteDatasourceImpl] instance.
  ServicesRemoteDatasourceImpl({
    required this.firestore,
    required this.functions,
  });

  @override
  Future<List<ServiceProfileEntity>> fetchWorkersByRadius({
    required GeoPoint center,
    required double radiusKm,
    String? skillFilter,
  }) async {
    Query query = firestore.collection('profiles').where('roles.worker', isEqualTo: true);

    if (skillFilter != null && skillFilter.trim().isNotEmpty) {
      query = query.where('skills', arrayContains: skillFilter.trim());
    }

    final snapshot = await query.get();
    final List<ServiceProfileEntity> results = [];

    for (final doc in snapshot.docs) {
      final model = ServiceProfileModel.fromFirestore(doc);
      final distance = _calculateHaversineDistance(
        center.latitude,
        center.longitude,
        model.location.latitude,
        model.location.longitude,
      );

      if (distance <= radiusKm) {
        results.add(model);
      }
    }

    // Sort by distance ascending
    results.sort((a, b) {
      final distA = _calculateHaversineDistance(center.latitude, center.longitude, a.location.latitude, a.location.longitude);
      final distB = _calculateHaversineDistance(center.latitude, center.longitude, b.location.latitude, b.location.longitude);
      return distA.compareTo(distB);
    });

    return results;
  }

  @override
  Future<ServiceProfileEntity> fetchWorkerProfile(String userId) async {
    final doc = await firestore.collection('profiles').doc(userId).get();
    if (!doc.exists) {
      throw Exception('Worker profile not found for user ID $userId');
    }
    return ServiceProfileModel.fromFirestore(doc);
  }

  @override
  Future<void> createServiceProfile(ServiceProfileModel profile) async {
    await firestore.collection('profiles').doc(profile.userId).set(
      profile.toMap(),
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> updateAvailability(String userId, WorkerAvailability status) async {
    await firestore.collection('profiles').doc(userId).update({
      'availabilityStatus': status.toCode(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<String> createServiceRequest(ServiceRequestModel request) async {
    try {
      final callable = functions.httpsCallable('createHireRequest');
      final response = await callable.call(request.toMap());
      final data = response.data as Map<String, dynamic>?;
      if (data != null && data.containsKey('requestId')) {
        return data['requestId'] as String;
      }
    } catch (_) {
      // Fallback: write directly to requests collection if Cloud Function is not yet deployed locally
    }

    final docRef = firestore.collection('requests').doc();
    final model = ServiceRequestModel(
      id: docRef.id,
      workerId: request.workerId,
      workerName: request.workerName,
      customerId: request.customerId,
      customerName: request.customerName,
      jobDescription: request.jobDescription,
      scheduledDate: request.scheduledDate,
      estimatedRate: request.estimatedRate,
      rateUnit: request.rateUnit,
      status: request.status,
      createdAt: request.createdAt,
    );

    await docRef.set(model.toMap());
    return docRef.id;
  }

  @override
  Future<List<ServiceRequestEntity>> fetchInboundJobs(String workerId) async {
    final snapshot = await firestore
        .collection('requests')
        .where('requestType', isEqualTo: 'service')
        .where('workerId', isEqualTo: workerId)
        .get();

    return snapshot.docs.map((doc) => ServiceRequestModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> acceptServiceRequest(String requestId) async {
    try {
      final callable = functions.httpsCallable('acceptHireRequest');
      await callable.call({'requestId': requestId});
      return;
    } catch (_) {
      // Fallback: update status in Firestore directly
    }

    await firestore.collection('requests').doc(requestId).update({
      'status': ServiceRequestStatus.accepted.toCode(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<ReviewEntity>> fetchWorkerReviews(String workerId) async {
    final snapshot = await firestore
        .collection('reviews')
        .where('workerId', isEqualTo: workerId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => ReviewEntity.fromFirestore(doc)).toList();
  }

  /// Calculates Earth surface distance in kilometers using the Haversine formula.
  double _calculateHaversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R * asin(...) where R = 6371 km
  }
}
