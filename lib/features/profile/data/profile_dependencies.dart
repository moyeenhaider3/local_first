import 'package:get_it/get_it.dart';
import 'package:local_first/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:local_first/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:local_first/features/profile/domain/repositories/profile_repository.dart';
import 'package:local_first/features/profile/presentation/cubits/profile_hub_cubit.dart';

/// PROFILE feature - Dependency Injection Setup
/// Registers profile remote datasource, repository, and cubit in GetIt service locator.
void initProfileDependencies(GetIt sl) {
  // Remote Datasource
  sl.registerLazySingleton<ProfileRemoteDatasource>(
    () => ProfileRemoteDatasourceImpl(
      firestore: sl(),
      functions: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDatasource: sl(),
    ),
  );

  // Cubit
  sl.registerFactory<ProfileHubCubit>(
    () => ProfileHubCubit(
      repository: sl(),
    ),
  );
}
