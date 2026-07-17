import 'package:get_it/get_it.dart';
import 'package:local_first/features/agreements/data/datasources/agreement_remote_datasource.dart';
import 'package:local_first/features/agreements/data/repositories/agreement_repository_impl.dart';
import 'package:local_first/features/agreements/domain/repositories/agreement_repository.dart';
import 'package:local_first/features/agreements/presentation/cubits/booking_cubit.dart';

/// Register all Booking & Contracting dependencies with the given [sl] GetIt instance.
void initBookingDependencies(GetIt sl) {
  // Datasources
  sl.registerLazySingleton<AgreementRemoteDatasource>(
    () => AgreementRemoteDatasourceImpl(
      firestore: sl(),
      functions: sl(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<AgreementRepository>(
    () => AgreementRepositoryImpl(sl()),
  );

  // Presentation (Cubits/Blocs)
  sl.registerFactory<BookingCubit>(
    () => BookingCubit(repository: sl()),
  );
}
