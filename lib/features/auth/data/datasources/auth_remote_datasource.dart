import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:local_first/core/error/exceptions.dart';
import 'package:local_first/features/auth/domain/entities/user_entity.dart';

/// AUTH feature - Data Layer: Remote Datasource
/// Handles remote communication for onboarding, SMS OTP authentication, and KYC.
/// Bound collections: users, profiles. Storage path: kyc/{uid}.
///
/// Firebase objects (UserCredential, ConfirmationResult) never escape this layer.
class AuthRemoteDatasource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  AuthRemoteDatasource({
    required this.firebaseAuth,
    required this.firestore,
    required this.storage,
  });

  /// Sends an SMS OTP to [phone] and resolves with the verificationId needed
  /// for [verifyOtp]. Uses a Completer to bridge the callback-based
  /// FirebaseAuth.verifyPhoneNumber API.
  Future<String> sendOtp(String phone) {
    final completer = Completer<String>();
    firebaseAuth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {
        if (!completer.isCompleted) completer.complete('auto');
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) {
          completer.completeError(AuthException(e.message ?? 'Failed to send OTP.'));
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!completer.isCompleted) completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (!completer.isCompleted) completer.complete(verificationId);
      },
    );
    return completer.future;
  }

  /// Signs in with the [verificationId] and [smsCode], returning the UID.
  Future<String> verifyOtp(String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await firebaseAuth.signInWithCredential(credential);
      final uid = userCredential.user?.uid;
      if (uid == null) {
        throw const AuthException('Authentication did not return a user.');
      }
      return uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'OTP verification failed.');
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Creates or merges the user document (users/{uid}) and a public profile
  /// document (profiles/{uid}).
  Future<void> upsertUserProfile(String uid, UserEntity entity) async {
    _assertNonEmptyUid(uid);
    try {
      final batch = firestore.batch();
      final userDoc = firestore.collection('users').doc(uid);
      final profileDoc = firestore.collection('profiles').doc(uid);

      batch.set(
        userDoc,
        {
          'phone': entity.phone,
          'displayName': entity.displayName,
          'photoUrl': entity.photoUrl,
          'roles': entity.roles,
          'verificationStatus': entity.verificationStatus,
          'kycDocumentUrl': entity.kycDocumentUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      batch.set(
        profileDoc,
        {
          'displayName': entity.displayName,
          'photoUrl': entity.photoUrl,
          'roles': entity.roles,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await batch.commit();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Uploads the KYC document image to Storage and returns its download URL.
  Future<String> setKycDocument(String uid, dynamic imageFile) async {
    _assertNonEmptyUid(uid);
    try {
      final ref = storage.ref().child('kyc/$uid/front.jpg');
      final uploadTask = ref.putData(
        await imageFile.readAsBytes(),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final snapshot = await uploadTask;
      return snapshot.ref.getDownloadURL();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Updates the verification status field on users/{uid}.
  /// Only 'unverified', 'pending', 'rejected' are client-writable; 'verified'
  /// is reserved for admin/Cloud Functions.
  Future<void> updateVerificationStatus(String uid, String status, {String? kycDocumentUrl}) async {
    _assertNonEmptyUid(uid);
    try {
      final data = <String, dynamic>{
        'verificationStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (kycDocumentUrl != null) {
        data['kycDocumentUrl'] = kycDocumentUrl;
      }
      await firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Uploads the profile avatar image to Storage and returns its download URL.
  Future<String> uploadProfileAvatar(String uid, dynamic imageFile) async {
    _assertNonEmptyUid(uid);
    try {
      final ref = storage.ref().child('avatars/$uid/profile.jpg');
      final uploadTask = ref.putData(
        await imageFile.readAsBytes(),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final snapshot = await uploadTask;
      return snapshot.ref.getDownloadURL();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Fetches the user document from Firestore (users/{uid}).
  /// Returns a Map if the document exists, or null otherwise.
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    _assertNonEmptyUid(uid);
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Signs out the active user session from Firebase Auth.
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }


  /// Guards every Firestore/Storage document path against empty UIDs so we
  /// surface a clear, actionable error instead of the generic
  /// "document path must be a non-empty string" from cloud_firestore.
  void _assertNonEmptyUid(String uid) {
    if (uid.isEmpty) {
      throw ArgumentError('Cannot write to Firestore with an empty UID.');
    }
  }
}
