import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_first/core/router/route_names.dart';
import 'package:local_first/features/auth/presentation/pages/home_page.dart';
import 'package:local_first/features/auth/presentation/pages/kyc_upload_page.dart';
import 'package:local_first/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:local_first/features/auth/presentation/pages/phone_login_page.dart';
import 'package:local_first/features/auth/presentation/pages/profile_setup_page.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) {
      final user = FirebaseAuth.instance.currentUser;
      final loggingIn = state.matchedLocation == '/' || state.matchedLocation == '/otp';

      if (user == null) {
        // Force login if trying to access protected screens
        if (!loggingIn) {
          return '/';
        }
      } else {
        // Redirect to home if logged in and trying to access login page
        if (loggingIn) {
          return '/home';
        }
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: RouteNames.phoneLogin,
        builder: (BuildContext context, GoRouterState state) {
          return const PhoneLoginPage();
        },
      ),
      GoRoute(
        path: '/otp',
        name: RouteNames.otp,
        builder: (BuildContext context, GoRouterState state) {
          final phone = state.extra as String? ?? '';
          return OtpVerificationPage(phone: phone);
        },
      ),
      GoRoute(
        path: '/profile_setup',
        name: RouteNames.profileSetup,
        builder: (BuildContext context, GoRouterState state) {
          return const ProfileSetupPage();
        },
      ),
      GoRoute(
        path: '/kyc_upload',
        name: RouteNames.kycUpload,
        builder: (BuildContext context, GoRouterState state) {
          return const KycUploadPage();
        },
      ),
      GoRoute(
        path: '/home',
        name: RouteNames.home,
        builder: (BuildContext context, GoRouterState state) {
          return const HomePage();
        },
      ),
    ],
  );
}
