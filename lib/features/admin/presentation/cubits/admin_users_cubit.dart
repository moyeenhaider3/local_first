import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_first/features/admin/domain/repositories/admin_repository.dart';
import 'package:local_first/features/admin/presentation/cubits/admin_users_state.dart';

/// ADMIN feature - Presentation Layer: User list & Admin role management Cubit
class AdminUsersCubit extends Cubit<AdminUsersState> {
  final AdminRepository repository;

  AdminUsersCubit({required this.repository}) : super(const AdminUsersInitial());

  /// Loads list of all users who are currently admins or superadmins
  Future<void> loadAdminUsers() async {
    emit(const AdminUsersLoading());
    final result = await repository.getAdminUsers();
    result.fold(
      (failure) => emit(AdminUsersError(failure.message)),
      (users) => emit(AdminUsersLoaded(users)),
    );
  }

  /// Searches users by display name prefix
  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      emit(const AdminUsersInitial());
      return;
    }
    emit(const AdminUsersLoading());
    final result = await repository.searchUsers(query);
    result.fold(
      (failure) => emit(AdminUsersError(failure.message)),
      (results) => emit(AdminUsersSearchResults(results)),
    );
  }

  /// Grants the 'admin' role to a user
  Future<void> grantAdmin(String uid) async {
    emit(const AdminUsersUpdating());
    final result = await repository.setAdminRole(uid, 'admin');
    result.fold(
      (failure) => emit(AdminUsersError(failure.message)),
      (_) {
        emit(const AdminUsersUpdated('Admin role granted successfully.'));
        loadAdminUsers();
      },
    );
  }

  /// Revokes administrative roles from a user (sets adminRole to null)
  Future<void> revokeAdmin(String uid) async {
    emit(const AdminUsersUpdating());
    final result = await repository.setAdminRole(uid, null);
    result.fold(
      (failure) => emit(AdminUsersError(failure.message)),
      (_) {
        emit(const AdminUsersUpdated('Admin role revoked successfully.'));
        loadAdminUsers();
      },
    );
  }
}
