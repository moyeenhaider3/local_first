import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:local_first/features/auth/data/auth_dependencies.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Initialize all app dependencies (Core services + Features).
Future<void> initDependencies() async {
  // External Core Services
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  // Features dependencies
  initAuthDependencies(sl);
}
