import 'package:flutter_test/flutter_test.dart';
import 'package:local_first/features/auth/domain/entities/user_entity.dart';
import 'package:local_first/features/auth/domain/repositories/auth_repository.dart';
import 'package:local_first/features/auth/domain/usecases/submit_kyc_usecase.dart';
import 'package:local_first/features/auth/presentation/cubits/auth_cubit.dart';

/// Fake repository for driving the cubit without Firebase.
class FakeAuthRepository implements AuthRepository {
  String? lastUid;
  String? lastImagePath;

  @override
  Future<String> sendOtp(String phone) async => 'verification-id-123';

  @override
  Future<String> verifyOtp(String verificationId, String smsCode) async => 'uid-abc';

  @override
  Future<void> upsertProfile(String uid, UserEntity entity) async {
    lastUid = uid;
  }

  @override
  Future<String> submitKyc({required String uid, required dynamic imageFile}) async {
    lastUid = uid;
    lastImagePath = imageFile as String?;
    return 'https://storage/kyc/$uid/front.jpg';
  }
}

void main() {
  late FakeAuthRepository repository;
  late SubmitKycUsecase submitKyc;

  setUp(() {
    repository = FakeAuthRepository();
    submitKyc = SubmitKycUsecase(repository);
  });

  test('verifyPhoneNumber emits [AuthLoading, OtpSentSuccess]', () async {
    final cubit = AuthCubit(repository, submitKyc);
    final states = <AuthState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.verifyPhoneNumber('+919999999999');
    await Future.delayed(Duration.zero);
    await sub.cancel();

    expect(states[0], isA<AuthLoading>());
    final success = states.last;
    expect(success, isA<OtpSentSuccess>());
    expect((success as OtpSentSuccess).verificationId, 'verification-id-123');
    await cubit.close();
  });

  test('verifyOtp emits [AuthLoading, AuthSuccess]', () async {
    final cubit = AuthCubit(repository, submitKyc);
    final states = <AuthState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.verifyPhoneNumber('+919999999999');
    await cubit.verifyOtp('123456');
    await Future.delayed(Duration.zero);
    await sub.cancel();

    expect(states.any((s) => s is AuthLoading), isTrue);
    final success = states.lastWhere((s) => s is AuthSuccess) as AuthSuccess;
    expect(success.uid, 'uid-abc');
    await cubit.close();
  });

  test('submitKyc emits [AuthLoading, KycSubmitted]', () async {
    final cubit = AuthCubit(repository, submitKyc);
    final states = <AuthState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.verifyPhoneNumber('+919999999999');
    await cubit.verifyOtp('123456');
    await cubit.submitKyc('path/to/image.jpg');
    await Future.delayed(Duration.zero);
    await sub.cancel();

    expect(states.any((s) => s is AuthLoading), isTrue);
    expect(states.any((s) => s is AuthSuccess), isTrue);
    final submitted =
        states.lastWhere((s) => s is KycSubmitted) as KycSubmitted;
    expect(submitted.kycDocumentUrl,
        'https://storage/kyc/uid-abc/front.jpg');
    await cubit.close();
  });
}
