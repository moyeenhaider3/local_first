import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_first/core/di/service_locator.dart';
import 'package:local_first/core/error/error_handler.dart';
import 'package:local_first/core/router/app_router.dart';
import 'package:local_first/core/theme/app_theme.dart';
import 'package:local_first/features/auth/presentation/cubits/auth_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize dependency injection service locator
  await initDependencies();

  // Initialize global error handling hooks
  ErrorHandler.init();
  if (kDebugMode) {
    await FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);
  }

  runApp(const AppRoot());
}

/// App root that wires the AUTH dependency graph via GoRouter and service locator.
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    // Resolve AuthCubit from DI and synchronize initial state if user is already logged in
    final authCubit = sl<AuthCubit>();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      authCubit.setAuthenticatedUser(currentUser.uid);
    }

    return BlocProvider<AuthCubit>(
      create: (_) => authCubit,
      child: MaterialApp.router(
        title: 'Local First',
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
