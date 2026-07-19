import 'package:get_it/get_it.dart';
import 'package:local_first/features/services/data/datasources/services_remote_datasource.dart';
import 'package:local_first/features/services/data/repositories/services_repository_impl.dart';
import 'package:local_first/features/services/domain/repositories/services_repository.dart';
import 'package:local_first/features/services/presentation/cubits/services_cubit.dart';

/// SERVICES feature - Dependency Injection Setup
/// Registers services remote datasource, repository, and cubits in GetIt container.
void initServicesDependencies(GetIt sl) {
  // Remote Datasource
  sl.registerLazySingleton<ServicesRemoteDatasource>(
    () => ServicesRemoteDatasourceImpl(
      firestore: sl(),
      functions: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<ServicesRepository>(
    () => ServicesRepositoryImpl(
      remoteDatasource: sl(),
    ),
  );

  // Cubit (Factory)
  sl.registerFactory<ServicesCubit>(
    () => ServicesCubit(
      repository: sl(),
    ),
  );
}
