import 'package:get_it/get_it.dart';
import 'package:local_first/core/cache/cache_manager.dart';
import 'package:local_first/features/listings/data/datasources/discovery_remote_datasource.dart';
import 'package:local_first/features/listings/data/datasources/mock_data_service.dart';
import 'package:local_first/features/listings/data/repositories/discovery_repository_impl.dart';
import 'package:local_first/features/listings/domain/entities/category_entity.dart';
import 'package:local_first/features/listings/domain/entities/listing_entity.dart';
import 'package:local_first/features/listings/domain/repositories/discovery_repository.dart';
import 'package:local_first/features/listings/presentation/cubits/discovery_cubit.dart';

/// Register all DISCOVERY feature dependencies with the given [sl] GetIt instance.
void initDiscoveryDependencies(GetIt sl) {
  // In-memory Cache Managers
  sl.registerLazySingleton<CacheManager<List<CategoryEntity>>>(
    () => CacheManager<List<CategoryEntity>>(),
  );
  sl.registerLazySingleton<CacheManager<List<ListingEntity>>>(
    () => CacheManager<List<ListingEntity>>(),
  );

  // Mock Data Service
  sl.registerLazySingleton<MockDataService>(
    () => MockDataService(firestore: sl()),
  );

  // Remote Datasource
  sl.registerLazySingleton<DiscoveryRemoteDatasource>(
    () => DiscoveryRemoteDatasourceImpl(
      firestore: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<DiscoveryRepository>(
    () => DiscoveryRepositoryImpl(
      remoteDatasource: sl(),
      categoriesCache: sl(),
      listingsCache: sl(),
    ),
  );

  // Cubit
  sl.registerFactory<DiscoveryCubit>(
    () => DiscoveryCubit(
      repository: sl(),
    ),
  );
}
