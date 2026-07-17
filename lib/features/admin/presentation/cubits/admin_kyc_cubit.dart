import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_first/features/admin/domain/repositories/admin_repository.dart';
import 'package:local_first/features/admin/presentation/cubits/admin_kyc_state.dart';

/// ADMIN feature - Presentation Layer: KYC review Cubit
class AdminKycCubit extends Cubit<AdminKycState> {
  final AdminRepository repository;

  AdminKycCubit({required this.repository}) : super(const AdminKycInitial());

  /// Fetches users with pending verification status
  Future<void> loadPendingKyc() async {
    emit(const AdminKycLoading());
    final result = await repository.getPendingKycUsers();
    result.fold(
      (failure) => emit(AdminKycError(failure.message)),
      (users) => emit(AdminKycLoaded(users)),
    );
  }

  /// Approves the KYC document for a user
  Future<void> approveKyc(String uid, String? remarks) async {
    emit(const AdminKycUpdating());
    final result = await repository.updateKycStatus(uid, 'verified', remarks);
    result.fold(
      (failure) => emit(AdminKycError(failure.message)),
      (_) {
        emit(const AdminKycUpdated('KYC approved successfully.'));
        loadPendingKyc();
      },
    );
  }

  /// Rejects the KYC document for a user
  Future<void> rejectKyc(String uid, String? remarks) async {
    emit(const AdminKycUpdating());
    final result = await repository.updateKycStatus(uid, 'rejected', remarks);
    result.fold(
      (failure) => emit(AdminKycError(failure.message)),
      (_) {
        emit(const AdminKycUpdated('KYC rejected successfully.'));
        loadPendingKyc();
      },
    );
  }
}
