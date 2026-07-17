import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_first/core/error/exceptions.dart';

/// ADMIN feature - Data Layer: Remote Datasource
/// Interface for admin-specific operations on users collection.
abstract class AdminRemoteDatasource {
  Future<List<Map<String, dynamic>>> getPendingKycUsers();
  Future<void> updateKycStatus(String uid, String status, String? remarks);
  Future<List<Map<String, dynamic>>> getAdminUsers();
  Future<List<Map<String, dynamic>>> searchUsers(String query);
  Future<void> setAdminRole(String uid, String? role);
}

class AdminRemoteDatasourceImpl implements AdminRemoteDatasource {
  final FirebaseFirestore firestore;

  AdminRemoteDatasourceImpl({required this.firestore});

  @override
  Future<List<Map<String, dynamic>>> getPendingKycUsers() async {
    try {
      final snapshot = await firestore
          .collection('users')
          .where('verificationStatus', isEqualTo: 'pending')
          .get();
      return snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'userId': doc.id,
              })
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateKycStatus(String uid, String status, String? remarks) async {
    try {
      await firestore.collection('users').doc(uid).update({
        'verificationStatus': status,
        'kycRemarks': remarks,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAdminUsers() async {
    try {
      final snapshot = await firestore
          .collection('users')
          .get();
      return snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'userId': doc.id,
              })
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final snapshot = await firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
          .get();
      return snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'userId': doc.id,
              })
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> setAdminRole(String uid, String? role) async {
    try {
      await firestore.collection('users').doc(uid).update({
        'adminRole': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
