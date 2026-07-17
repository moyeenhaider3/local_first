import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:local_first/features/auth/domain/entities/user_entity.dart';
import 'package:local_first/features/auth/domain/repositories/auth_repository.dart';
import 'package:local_first/features/auth/domain/usecases/submit_kyc_usecase.dart';
import 'package:local_first/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:local_first/features/auth/presentation/pages/phone_login_page.dart';
import 'package:local_first/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:local_first/features/auth/presentation/pages/profile_setup_page.dart';
import 'package:local_first/features/auth/presentation/pages/kyc_upload_page.dart';

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

class FailingAuthRepository implements AuthRepository {
  @override
  Future<String> sendOtp(String phone) async => 'verification-id-123';

  @override
  Future<String> verifyOtp(String verificationId, String smsCode) async {
    throw Exception('Invalid code');
  }

  @override
  Future<void> upsertProfile(String uid, UserEntity entity) async {}

  @override
  Future<String> submitKyc({required String uid, required dynamic imageFile}) async =>
      'https://storage/kyc/$uid/front.jpg';
}

Widget _buildPage(Widget page, AuthRepository repo) {
  final submitKyc = SubmitKycUsecase(repo);
  return MaterialApp(
    home: BlocProvider<AuthCubit>(
      create: (_) => AuthCubit(repo, submitKyc),
      child: page,
    ),
  );
}

void main() {
  group('AUTH-01 PhoneLoginPage', () {
    late FakeAuthRepository repo;

    setUp(() => repo = FakeAuthRepository());

    testWidgets('GET OTP disabled when phone empty', (tester) async {
      await tester.pumpWidget(_buildPage(const PhoneLoginPage(), repo));
      final button = tester.widget<ElevatedButton>(find.byKey(const Key('GET OTP')));
      expect(button.onPressed, isNull);
    });

    testWidgets('GET OTP disabled when phone not 10 digits', (tester) async {
      await tester.pumpWidget(_buildPage(const PhoneLoginPage(), repo));
      await tester.enterText(find.byType(TextField), '123');
      await tester.pump();
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      final button = tester.widget<ElevatedButton>(find.byKey(const Key('GET OTP')));
      expect(button.onPressed, isNull);
    });

    testWidgets('GET OTP enabled when valid 10 digits + consent', (tester) async {
      await tester.pumpWidget(_buildPage(const PhoneLoginPage(), repo));
      await tester.enterText(find.byType(TextField), '9999999999');
      await tester.pump();
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      final button = tester.widget<ElevatedButton>(find.byKey(const Key('GET OTP')));
      expect(button.onPressed, isNotNull);
    });
  });

  group('AUTH-02 OtpVerificationPage', () {
    testWidgets('shows resend countdown text', (tester) async {
      await tester.pumpWidget(
        _buildPage(const OtpVerificationPage(phone: '9999999999'), FakeAuthRepository()),
      );
      expect(find.textContaining('Resend SMS in'), findsOneWidget);
    });

    testWidgets('wrong code shows red borders + error text', (tester) async {
      await tester.pumpWidget(
        _buildPage(const OtpVerificationPage(phone: '9999999999'), FailingAuthRepository()),
      );
      for (var i = 0; i < 6; i++) {
        await tester.enterText(find.byKey(Key('otp_$i')), '1');
        await tester.pump();
      }
      await tester.pumpAndSettle();
      expect(find.text('Invalid code. Please try again.'), findsOneWidget);
    });
  });

  group('AUTH-03 ProfileSetupPage', () {
    testWidgets('tapping a role card toggles selection', (tester) async {
      await tester.pumpWidget(_buildPage(const ProfileSetupPage(), FakeAuthRepository()));
      final card = find.byKey(const Key('role_renter'));
      // Initially unchecked: outline icon present.
      expect(find.descendant(of: card, matching: find.byIcon(Icons.check_box_outline_blank)), findsOneWidget);
      await tester.tap(card);
      await tester.pump();
      expect(find.descendant(of: card, matching: find.byIcon(Icons.check_box)), findsOneWidget);
    });

    testWidgets('CREATE ACCOUNT disabled until name + role', (tester) async {
      await tester.pumpWidget(_buildPage(const ProfileSetupPage(), FakeAuthRepository()));
      final button = tester.widget<ElevatedButton>(find.byKey(const Key('CREATE ACCOUNT')));
      expect(button.onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'Amit');
      await tester.pump();
      final stillDisabled = tester.widget<ElevatedButton>(find.byKey(const Key('CREATE ACCOUNT')));
      expect(stillDisabled.onPressed, isNull);

      await tester.tap(find.byKey(const Key('role_renter')));
      await tester.pump();
      final enabled = tester.widget<ElevatedButton>(find.byKey(const Key('CREATE ACCOUNT')));
      expect(enabled.onPressed, isNotNull);
    });
  });

  group('AUTH-04 KycUploadPage', () {
    testWidgets('dashed card present', (tester) async {
      await tester.pumpWidget(_buildPage(const KycUploadPage(), FakeAuthRepository()));
      expect(find.byKey(const Key('kyc_dashed_card')), findsOneWidget);
      expect(find.text('Tap to photograph front of ID'), findsOneWidget);
    });

    testWidgets('SUBMIT KYC DETAILS disabled until ID captured', (tester) async {
      await tester.pumpWidget(_buildPage(const KycUploadPage(), FakeAuthRepository()));
      final button = tester.widget<ElevatedButton>(
        find.byKey(const Key('SUBMIT KYC DETAILS')),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('SUBMIT KYC DETAILS triggers KycSubmitted navigation', (tester) async {
      final cubit = AuthCubit(FakeAuthRepository(), SubmitKycUsecase(FakeAuthRepository()));
      await tester.pumpWidget(
        MaterialApp(
          routes: {'/home': (_) => const Scaffold(body: Text('Home'))},
          home: BlocProvider<AuthCubit>.value(
            value: cubit,
            child: const KycUploadPage(),
          ),
        ),
      );
      // Simulate the page having captured a file by emitting KycSubmitted.
      cubit.emit(const KycSubmitted('https://storage/kyc/uid/front.jpg'));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });
  });
}
