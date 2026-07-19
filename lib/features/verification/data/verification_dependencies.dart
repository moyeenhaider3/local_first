import 'package:get_it/get_it.dart';
import 'package:local_first/features/verification/data/datasources/verification_remote_datasource.dart';
import 'package:local_first/features/verification/data/repositories/verification_repository_impl.dart';
import 'package:local_first/features/verification/domain/repositories/verification_repository.dart';
import 'package:local_first/features/verification/presentation/cubits/verification_cubit.dart';

/// Registers all verification feature dependencies with the given [sl] GetIt instance.
void initVerificationDependencies(GetIt sl) {
  // Datasource
  sl.registerLazySingleton<VerificationRemoteDatasource>(
    () => VerificationRemoteDatasourceImpl(
      firestore: sl(),
      functions: sl(),
      storage: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<VerificationRepository>(
    () => VerificationRepositoryImpl(sl()),
  );

  // Presentation (Cubits/Blocs)
  sl.registerFactory<VerificationCubit>(
    () => VerificationCubit(sl()),
  );
}
