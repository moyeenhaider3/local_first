import 'package:equatable/equatable.dart';
import 'package:local_first/features/auth/domain/entities/user_entity.dart';

sealed class AdminUsersState extends Equatable {
  const AdminUsersState();

  @override
  List<Object?> get props => [];
}

class AdminUsersInitial extends AdminUsersState {
  const AdminUsersInitial();
}

class AdminUsersLoading extends AdminUsersState {
  const AdminUsersLoading();
}

class AdminUsersLoaded extends AdminUsersState {
  final List<UserEntity> adminUsers;

  const AdminUsersLoaded(this.adminUsers);

  @override
  List<Object?> get props => [adminUsers];
}

class AdminUsersSearchResults extends AdminUsersState {
  final List<UserEntity> results;

  const AdminUsersSearchResults(this.results);

  @override
  List<Object?> get props => [results];
}

class AdminUsersUpdating extends AdminUsersState {
  const AdminUsersUpdating();
}

class AdminUsersUpdated extends AdminUsersState {
  final String message;

  const AdminUsersUpdated(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminUsersError extends AdminUsersState {
  final String message;

  const AdminUsersError(this.message);

  @override
  List<Object?> get props => [message];
}
