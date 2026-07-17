import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local_first/core/error/failures.dart';
import 'package:local_first/features/auth/domain/entities/user_entity.dart';
import 'package:local_first/features/auth/domain/repositories/auth_repository.dart';

part 'auth_state.dart';

/// AUTH feature - Presentation Layer: Auth Cubit
/// Manages auth state transitions:
/// AuthInitial, AuthLoading, OtpSentSuccess, AuthSuccess, KycSubmitted, AuthError.
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;

  String? _verificationId;
  String? _uid;
  String? _phone;

  AuthCubit({
    required this.repository,
  }) : super(const AuthInitial());

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    _phone = phoneNumber;
    emit(const AuthLoading());
    final result = await repository.sendOtp(phoneNumber);
    result.fold(
      (failure) => emit(AuthError(failure)),
      (verificationId) {
        _verificationId = verificationId;
        emit(OtpSentSuccess(verificationId));
      },
    );
  }

  Future<void> verifyOtp(String smsCode) async {
    emit(const AuthLoading());
    if (_verificationId == null) {
      emit(const AuthError(AuthFailure('No verification session started.')));
      return;
    }
    final result = await repository.verifyOtp(_verificationId!, smsCode);
    await result.fold(
      (failure) async => emit(AuthError(failure)),
      (uid) async {
        _uid = uid;
        final userResult = await repository.getUser(uid);
        userResult.fold(
          (failure) => emit(AuthSuccess(uid, hasProfile: false, hasKyc: false)),
          (userEntity) {
            if (userEntity == null) {
              emit(AuthSuccess(uid, hasProfile: false, hasKyc: false));
            } else {
              final hasProfile =
                  userEntity.displayName != null && userEntity.displayName!.isNotEmpty;
              final hasKyc =
                  userEntity.kycDocumentUrl != null && userEntity.kycDocumentUrl!.isNotEmpty;
              emit(AuthSuccess(uid, hasProfile: hasProfile, hasKyc: hasKyc, userEntity: userEntity));
            }
          },
        );
      },
    );
  }

  Future<void> createProfile(UserEntity entity) async {
    emit(const AuthLoading());
    final uid = _uid;
    if (uid == null || uid.isEmpty) {
      emit(const AuthError(AuthFailure('Cannot create profile before phone verification.')));
      return;
    }
    // Inject the verified phone so the stored profile is complete even if
    // the UI screen didn't pass it through.
    final complete = entity.copyWith(userId: uid, phone: _phone ?? entity.phone);
    final result = await repository.upsertProfile(uid, complete);
    result.fold(
      (failure) => emit(AuthError(failure)),
      (_) => emit(AuthSuccess(uid, hasProfile: true, hasKyc: false, userEntity: complete)),
    );
  }

  Future<void> submitKyc(dynamic imageFile) async {
    emit(const AuthLoading());
    final uid = _uid;
    if (uid == null) {
      emit(const AuthError(AuthFailure('Cannot submit KYC before authentication.')));
      return;
    }
    final result = await repository.submitKyc(uid: uid, imageFile: imageFile);
    result.fold(
      (failure) => emit(AuthError(failure)),
      (url) => emit(KycSubmitted(url)),
    );
  }

  /// Sets the currently active user ID directly. Useful for initial auth state.
  void setAuthenticatedUser(String uid) {
    _uid = uid;
    emit(AuthSuccess(uid, hasProfile: true, hasKyc: true));
    _loadUserProfile(uid);
  }

  Future<void> _loadUserProfile(String uid) async {
    final result = await repository.getUser(uid);
    result.fold(
      (failure) {},
      (userEntity) {
        if (userEntity != null) {
          final hasProfile =
              userEntity.displayName != null && userEntity.displayName!.isNotEmpty;
          final hasKyc =
              userEntity.kycDocumentUrl != null && userEntity.kycDocumentUrl!.isNotEmpty;
          emit(AuthSuccess(uid, hasProfile: hasProfile, hasKyc: hasKyc, userEntity: userEntity));
        }
      },
    );
  }
}
