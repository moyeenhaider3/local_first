import 'package:get_it/get_it.dart';
import 'package:local_first/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:local_first/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:local_first/features/auth/domain/repositories/auth_repository.dart';
import 'package:local_first/features/auth/presentation/cubits/auth_cubit.dart';

/// Register all AUTH feature dependencies with the given [sl] GetIt instance.
void initAuthDependencies(GetIt sl) {
  // Datasource
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasource(
      firebaseAuth: sl(),
      firestore: sl(),
      storage: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  // Presentation (Cubits/Blocs)
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(
      repository: sl(),
    ),
  );
}
