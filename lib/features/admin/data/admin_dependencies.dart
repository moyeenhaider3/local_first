import 'package:get_it/get_it.dart';
import 'package:local_first/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:local_first/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:local_first/features/admin/domain/repositories/admin_repository.dart';
import 'package:local_first/features/admin/presentation/cubits/admin_kyc_cubit.dart';
import 'package:local_first/features/admin/presentation/cubits/admin_users_cubit.dart';

/// Register all ADMIN feature dependencies with the given [sl] GetIt instance.
void initAdminDependencies(GetIt sl) {
  // Datasource
  sl.registerLazySingleton<AdminRemoteDatasource>(
    () => AdminRemoteDatasourceImpl(firestore: sl()),
  );

  // Repository
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(remoteDatasource: sl()),
  );

  // Presentation (Cubits)
  sl.registerFactory<AdminKycCubit>(
    () => AdminKycCubit(repository: sl()),
  );
  sl.registerFactory<AdminUsersCubit>(
    () => AdminUsersCubit(repository: sl()),
  );
}
