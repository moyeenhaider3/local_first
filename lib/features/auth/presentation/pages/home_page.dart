import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_first/core/router/route_names.dart';
import 'package:local_first/core/theme/app_theme.dart';

/// Post-auth landing screen shown after successful KYC submission.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    context.goNamed(RouteNames.phoneLogin);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Local First')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(spacing.edgeMargin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_user,
                size: 56,
                color: theme.colorScheme.primary,
              ),
              SizedBox(height: spacing.space16),
              Text(
                'KYC Submitted Successfully',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing.space8),
              Text(
                'Welcome to your home page.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing.space24),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('LOG OUT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.surface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
