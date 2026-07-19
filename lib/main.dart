import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_first/core/di/service_locator.dart';
import 'package:local_first/core/error/error_handler.dart';
import 'package:local_first/core/router/app_router.dart';
import 'package:local_first/core/theme/app_theme.dart';
import 'package:local_first/core/notifications/fcm_service.dart';
import 'package:local_first/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:local_first/features/listings/data/datasources/mock_data_service.dart';
import 'package:local_first/features/listings/presentation/cubits/discovery_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Point to local Firebase Emulators in debug/development mode
  // if (kDebugMode) {
  //   final host = defaultTargetPlatform == TargetPlatform.android
  //       ? '10.0.2.2'
  //       : 'localhost';
  //   FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  //   FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
  //   debugPrint('Connecting to Firebase Emulators on host: $host');
  // }

  // Initialize dependency injection service locator
  await initDependencies();

  // Initialize FCM notification service
  await sl<FcmService>().init();

  // Populate mock data if empty
  await sl<MockDataService>().populateIfEmpty();

  // Initialize global error handling hooks
  ErrorHandler.init();
  if (kDebugMode) {
    await FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: true,
    );
  }
  // if (kDebugMode) {
  //   // Use '10.0.2.2' for Android Emulator to connect to host computer's localhost, otherwise 'localhost'
  //   final host = defaultTargetPlatform == TargetPlatform.android
  //       ? '10.0.2.2'
  //       : 'localhost';

  //   FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  //   FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
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
