import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:local_first/core/notifications/fcm_service.dart';
import 'package:local_first/features/admin/data/admin_dependencies.dart';
import 'package:local_first/features/agreements/data/agreement_timeline_dependencies.dart';
import 'package:local_first/features/agreements/data/booking_dependencies.dart';
import 'package:local_first/features/auth/data/auth_dependencies.dart';
import 'package:local_first/features/listings/data/discovery_dependencies.dart';
import 'package:local_first/features/verification/data/verification_dependencies.dart';

import 'package:local_first/features/payments/data/payment_dependencies.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Initialize all app dependencies (Core services + Features).
Future<void> initDependencies() async {
  // External Core Services
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  sl.registerLazySingleton<FirebaseFunctions>(() => FirebaseFunctions.instance);
  sl.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);

  // Notifications
  sl.registerLazySingleton<FcmService>(() => FcmService(
        messaging: sl(),
        firestore: sl(),
        auth: sl(),
      ));

  // Features dependencies
  initAuthDependencies(sl);
  initDiscoveryDependencies(sl);
  initAdminDependencies(sl);
  initBookingDependencies(sl);
  initVerificationDependencies(sl);
  initAgreementDependencies(sl);
  initPaymentDependencies(sl);
  initHireDependencies(sl);
  initProfileDependencies(sl);
}

// Future features DI stubs (implemented in respective booking, verification, agreement, hire, and profile phases)
void initAgreementDependencies(GetIt sl) {
  initAgreementTimelineDependencies(sl);
}
void initHireDependencies(GetIt sl) {}
void initProfileDependencies(GetIt sl) {}
