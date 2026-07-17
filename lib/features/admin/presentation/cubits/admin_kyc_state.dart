import 'package:equatable/equatable.dart';
import 'package:local_first/features/auth/domain/entities/user_entity.dart';

sealed class AdminKycState extends Equatable {
  const AdminKycState();

  @override
  List<Object?> get props => [];
}

class AdminKycInitial extends AdminKycState {
  const AdminKycInitial();
}

class AdminKycLoading extends AdminKycState {
  const AdminKycLoading();
}

class AdminKycLoaded extends AdminKycState {
  final List<UserEntity> pendingUsers;

  const AdminKycLoaded(this.pendingUsers);

  @override
  List<Object?> get props => [pendingUsers];
}

class AdminKycUpdating extends AdminKycState {
  const AdminKycUpdating();
}

class AdminKycUpdated extends AdminKycState {
  final String message;

  const AdminKycUpdated(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminKycError extends AdminKycState {
  final String message;

  const AdminKycError(this.message);

  @override
  List<Object?> get props => [message];
}
