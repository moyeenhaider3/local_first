import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local_first/features/auth/domain/entities/user_entity.dart';
import 'package:local_first/features/auth/domain/repositories/auth_repository.dart';
import 'package:local_first/features/auth/domain/usecases/submit_kyc_usecase.dart';

part 'auth_state.dart';

/// AUTH feature - Presentation Layer: Auth Cubit
/// Manages auth state transitions:
/// AuthInitial, AuthLoading, OtpSentSuccess, AuthSuccess, KycSubmitted, AuthError.
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;
  final SubmitKycUsecase submitKycUsecase;
  String? _verificationId;
  String? _uid;
  String? _phone;

  AuthCubit(this.repository, this.submitKycUsecase) : super(const AuthInitial());

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    _phone = phoneNumber;
    emit(const AuthLoading());
    try {
      _verificationId = await repository.sendOtp(phoneNumber);
      emit(OtpSentSuccess(_verificationId!));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> verifyOtp(String smsCode) async {
    emit(const AuthLoading());
    try {
      if (_verificationId == null) {
        throw Exception('No verification session started.');
      }
      _uid = await repository.verifyOtp(_verificationId!, smsCode);
      emit(AuthSuccess(_uid!));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> createProfile(UserEntity entity) async {
    emit(const AuthLoading());
    try {
      // The authoritative UID was captured during verifyOtp. The entity's
      // userId/phone are UI placeholders and must NOT overwrite it.
      final uid = _uid;
      if (uid == null || uid.isEmpty) {
        throw StateError('Cannot create profile before phone verification.');
      }
      // Inject the verified phone so the stored profile is complete even if
      // the UI screen didn't pass it through.
      final complete = entity.copyWith(userId: uid, phone: _phone ?? entity.phone);
      await repository.upsertProfile(uid, complete);
      emit(AuthSuccess(uid));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> submitKyc(dynamic imageFile) async {
    emit(const AuthLoading());
    try {
      if (_uid == null) {
        throw Exception('Cannot submit KYC before authentication.');
      }
      final url = await submitKycUsecase.call(uid: _uid!, imageFile: imageFile);
      emit(KycSubmitted(url));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
