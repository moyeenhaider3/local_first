import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_first/core/router/route_names.dart';
import 'package:local_first/core/theme/app_theme.dart';

/// Reusable placeholder page for future modules.
class PlaceholderPage extends StatelessWidget {
  final String tabName;

  const PlaceholderPage({
    super.key,
    required this.tabName,
  });

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    context.goNamed(RouteNames.phoneLogin);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    IconData getIcon() {
      switch (tabName.toLowerCase()) {
        case 'home':
          return Icons.explore;
        case 'rent':
          return Icons.inventory_2;
        case 'hire':
          return Icons.handyman;
        case 'activity':
          return Icons.receipt_long;
        case 'profile':
          return Icons.person;
        default:
          return Icons.help_outline;
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(tabName),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(spacing.edgeMargin),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                getIcon(),
                size: 48,
                color: theme.colorScheme.primary,
              ),
              SizedBox(height: spacing.space16),
              Text(
                'Coming Soon — $tabName',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing.space8),
              Text(
                tabName,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              if (tabName.toLowerCase() == 'profile') ...[
                SizedBox(height: spacing.space24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('LOG OUT'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
