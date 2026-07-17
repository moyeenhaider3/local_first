part of 'auth_cubit.dart';

/// AUTH feature - Presentation Layer: Auth State
/// Sealed state hierarchy for the authentication flow.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class OtpSentSuccess extends AuthState {
  final String verificationId;

  const OtpSentSuccess(this.verificationId);

  @override
  List<Object?> get props => [verificationId];
}

final class AuthSuccess extends AuthState {
  final String uid;

  const AuthSuccess(this.uid);

  @override
  List<Object?> get props => [uid];
}

final class KycSubmitted extends AuthState {
  final String kycDocumentUrl;

  const KycSubmitted(this.kycDocumentUrl);

  @override
  List<Object?> get props => [kycDocumentUrl];
}

final class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
