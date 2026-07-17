import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:local_first/core/theme/design_tokens.dart';
import 'package:local_first/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:local_first/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:local_first/features/auth/domain/repositories/auth_repository.dart';
import 'package:local_first/features/auth/domain/usecases/submit_kyc_usecase.dart';
import 'package:local_first/features/auth/presentation/cubits/auth_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const AppRoot());
}

/// App root that wires the AUTH dependency graph via provider composition.
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final datasource = AuthRemoteDatasource(
      firebaseAuth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
      storage: FirebaseStorage.instance,
    );
    final repository = AuthRepositoryImpl(datasource);
    final submitKyc = SubmitKycUsecase(repository);

    return RepositoryProvider<AuthRepository>.value(
      value: repository,
      child: BlocProvider<AuthCubit>(
        create: (_) => AuthCubit(repository, submitKyc),
        child: MaterialApp(
          title: 'Local First',
          theme: ThemeData(
            scaffoldBackgroundColor: DesignTokens.colorBgDark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: DesignTokens.colorPrimary,
              primary: DesignTokens.colorPrimary,
            ),
            useMaterial3: true,
          ),
          home: const AuthBootstrap(),
        ),
      ),
    );
  }
}

/// Placeholder home — replaced by AUTH UI screens in plan 01-02.
class AuthBootstrap extends StatelessWidget {
  const AuthBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.colorBgDark,
      body: Center(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return Text(
              'Local First',
              style: DesignTokens.h1.copyWith(color: DesignTokens.colorPrimary),
            );
          },
        ),
      ),
    );
  }
}
