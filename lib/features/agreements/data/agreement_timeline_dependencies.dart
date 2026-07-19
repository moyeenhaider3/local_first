import 'package:get_it/get_it.dart';
import 'package:local_first/features/agreements/domain/repositories/agreement_repository.dart';
import 'package:local_first/features/agreements/presentation/cubits/agreement_timeline_cubit.dart';
import 'package:local_first/features/verification/domain/repositories/verification_repository.dart';

import 'package:local_first/features/agreements/presentation/cubits/transactions_cubit.dart';

/// Registers GetIt dependency injection for the Agreement Timeline & History features.
void initAgreementTimelineDependencies(GetIt sl) {
  if (!sl.isRegistered<AgreementTimelineCubit>()) {
    sl.registerFactory<AgreementTimelineCubit>(
      () => AgreementTimelineCubit(
        agreementRepository: sl<AgreementRepository>(),
        verificationRepository: sl<VerificationRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<TransactionsCubit>()) {
    sl.registerFactory<TransactionsCubit>(
      () => TransactionsCubit(
        agreementRepository: sl<AgreementRepository>(),
        auth: sl(),
      ),
    );
  }
}
