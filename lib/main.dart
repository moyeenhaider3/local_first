import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_first/core/di/service_locator.dart';
import 'package:local_first/core/error/error_handler.dart';
import 'package:local_first/core/notifications/fcm_service.dart';
import 'package:local_first/core/router/app_router.dart';
import 'package:local_first/core/theme/app_theme.dart';
import 'package:local_first/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:local_first/features/listings/data/datasources/mock_data_service.dart';
import 'package:local_first/features/listings/presentation/cubits/discovery_cubit.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();

  // Initialize dependency injection service locator
  await initDependencies();

  // Initialize FCM notification service
  await sl<FcmService>().init();

  // Populate mock data if empty
  await sl<MockDataService>().populateIfEmpty();

  // Initialize global error handling hooks
  ErrorHandler.init();
  // if (kDebugMode) {
  //   await FirebaseAuth.instance.setSettings(
  //     appVerificationDisabledForTesting: true,
  //   );
  // }

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

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => authCubit),
        BlocProvider<DiscoveryCubit>(create: (_) => sl<DiscoveryCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Local First',
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
