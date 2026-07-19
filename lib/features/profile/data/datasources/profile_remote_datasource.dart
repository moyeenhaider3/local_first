import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:local_first/features/profile/data/models/review_model.dart';
import 'package:local_first/features/profile/data/models/support_ticket_model.dart';

/// PROFILE feature - Data Layer: Profile Remote Datasource Contract
/// Interface for profile, reviews, support tickets, and server-side trust score operations.
abstract class ProfileRemoteDatasource {
  /// Submits a user/worker/rental review to Firestore.
  Future<void> submitReview(ReviewModel review);

  /// Fetches reviews received by a target user or listing.
  Future<List<ReviewModel>> fetchUserReviews(String targetId);

  /// Submits a user support ticket to Firestore.
  Future<void> createSupportTicket(SupportTicketModel ticket);

  /// Fetches support tickets created by a specific user.
  Future<List<SupportTicketModel>> fetchUserSupportTickets(String userId);

  /// Invokes the [calculateTrustScore] Cloud Function to re-calculate trust score.
  Future<int> calculateTrustScore(String userId);
}

/// Concrete implementation of [ProfileRemoteDatasource] using Firestore & FirebaseFunctions.
class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  /// Cloud Firestore instance.
  final FirebaseFirestore firestore;

  /// Firebase Functions instance.
  final FirebaseFunctions functions;

  /// Creates a [ProfileRemoteDatasourceImpl] instance.
  ProfileRemoteDatasourceImpl({
    required this.firestore,
    required this.functions,
  });

  @override
  Future<void> submitReview(ReviewModel review) async {
    final docRef = firestore.collection('reviews').doc(review.id.isNotEmpty ? review.id : null);
    await docRef.set(review.toMap(), SetOptions(merge: true));
  }

  @override
  Future<List<ReviewModel>> fetchUserReviews(String targetId) async {
    final snapshot = await firestore
        .collection('reviews')
        .where('targetId', isEqualTo: targetId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> createSupportTicket(SupportTicketModel ticket) async {
    final docRef = firestore.collection('support_tickets').doc(ticket.id.isNotEmpty ? ticket.id : null);
    await docRef.set(ticket.toMap(), SetOptions(merge: true));
  }

  @override
  Future<List<SupportTicketModel>> fetchUserSupportTickets(String userId) async {
    final snapshot = await firestore
        .collection('support_tickets')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => SupportTicketModel.fromFirestore(doc)).toList();
  }

  @override
  Future<int> calculateTrustScore(String userId) async {
    final callable = functions.httpsCallable('calculateTrustScore');
    final response = await callable.call({'userId': userId});
    final data = response.data as Map<String, dynamic>? ?? {};
    final score = data['trustScore'] as num? ?? 50;
    return score.toInt();
  }
}
