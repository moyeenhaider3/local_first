import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:local_first/features/payments/data/datasources/payment_remote_datasource.dart';
import 'package:local_first/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:local_first/features/payments/domain/repositories/payment_repository.dart';
import 'package:local_first/features/payments/presentation/cubits/payment_cubit.dart';

/// Registers all payment feature dependencies into the provided [sl] GetIt instance.
void initPaymentDependencies(GetIt sl) {
  // Datasource
  sl.registerLazySingleton<PaymentRemoteDatasource>(
    () => PaymentRemoteDatasourceImpl(
      firestore: sl<FirebaseFirestore>(),
      functions: sl<FirebaseFunctions>(),
      storage: sl<FirebaseStorage>(),
    ),
  );

  // Repository
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(sl<PaymentRemoteDatasource>()),
  );

  // Presentation (Cubits)
  sl.registerFactory<PaymentCubit>(
    () => PaymentCubit(sl<PaymentRepository>()),
  );
}
