import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Top-level background message handler for Firebase Cloud Messaging.
/// This must be annotated with @pragma('vm:entry-point') to prevent tree shaking
/// as it runs in a separate isolate when the app is in the background or terminated.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background notification logging or task execution.
  // Note: Firebase.initializeApp() is already called in the main isolate, but may be needed here.
  debugPrint('Handling a background message: ${message.messageId}');
}

/// A service that manages Firebase Cloud Messaging (FCM) notifications for Local First.
/// Implements permission requesting, token retrieval, Firestore synchronization,
/// and message handling in foreground and background states.
class FcmService {
  /// The FirebaseMessaging instance.
  final FirebaseMessaging _messaging;

  /// The FirebaseFirestore instance.
  final FirebaseFirestore _firestore;

  /// The FirebaseAuth instance.
  final FirebaseAuth _auth;

  /// StreamController to dispatch foreground messages to any listener.
  final StreamController<RemoteMessage> _foregroundMessageController =
      StreamController<RemoteMessage>.broadcast();

  /// Stream of incoming foreground notifications for the UI or other services.
  Stream<RemoteMessage> get foregroundMessages => _foregroundMessageController.stream;

  /// Subscription to authentication state changes.
  StreamSubscription<User?>? _authSubscription;

  /// Subscription to token refresh events.
  StreamSubscription<String>? _tokenRefreshSubscription;

  /// Creates an [FcmService] instance.
  FcmService({
    required FirebaseMessaging messaging,
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _messaging = messaging,
        _firestore = firestore,
        _auth = auth;

  /// Initializes the FCM service.
  /// Sets up message handlers, requests permissions, and starts token synchronization.
  Future<void> init() async {
    // 1. Request notification permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('User notification permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // 2. Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 3. Setup foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Received a foreground message: ${message.notification?.title}');
        _foregroundMessageController.add(message);
      });

      // 4. Start token synchronization
      _setupTokenSync();
    }
  }

  /// Sets up listeners to automatically synchronize the FCM token with Firestore
  /// when the user signs in or when the token is refreshed by the system.
  void _setupTokenSync() {
    // Listen to token refresh events
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((String token) {
      debugPrint('FCM Token refreshed');
      _saveTokenToFirestore(token);
    });

    // Synchronize whenever authentication state changes (login/logout)
    _authSubscription = _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        final token = await _messaging.getToken();
        if (token != null) {
          await _saveTokenToFirestore(token);
        }
      } else {
        debugPrint('User signed out, skipping token sync');
      }
    });
  }

  /// Saves the device FCM token to the user's tokens subcollection in Firestore.
  /// Uses the SHA-256 hash of the token as the document ID for safety and uniqueness.
  ///
  /// [token] The Firebase Cloud Messaging registration token.
  Future<void> _saveTokenToFirestore(String token) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      // Hash token to create a clean, safe document ID free of special characters.
      final tokenId = sha256.convert(utf8.encode(token)).toString();

      final tokenRef = _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('tokens')
          .doc(tokenId);

      await tokenRef.set({
        'token': token,
        'platform': kIsWeb ? 'web' : Platform.operatingSystem,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('FCM Token synchronized successfully for user: ${currentUser.uid}');
    } catch (e) {
      debugPrint('Failed to save FCM token to Firestore: $e');
    }
  }

  /// Cleans up subscriptions and resources when the service is disposed.
  void dispose() {
    _authSubscription?.cancel();
    _tokenRefreshSubscription?.cancel();
    _foregroundMessageController.close();
  }
}
