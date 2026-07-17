import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_first/core/router/route_names.dart';
import 'package:local_first/core/theme/app_theme.dart';
import 'package:local_first/features/auth/domain/entities/user_entity.dart';
import 'package:local_first/features/auth/presentation/cubits/auth_cubit.dart';

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

    // Retrieve the user entity from AuthCubit state to check admin role
    final authState = context.watch<AuthCubit>().state;
    UserEntity? currentUser;
    if (authState is AuthSuccess) {
      currentUser = authState.userEntity;
    }

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
                Card(
                  color: theme.colorScheme.surface,
                  child: Padding(
                    padding: EdgeInsets.all(spacing.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Profile Data',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const Divider(),
                        SizedBox(height: spacing.space8),
                        _buildProfileField(context, 'User ID', currentUser?.userId ?? 'N/A'),
                        _buildProfileField(context, 'Name', currentUser?.displayName ?? 'N/A'),
                        _buildProfileField(context, 'Phone', currentUser?.phone ?? 'N/A'),
                        _buildProfileField(
                          context,
                          'Verification Status',
                          (currentUser?.verificationStatus ?? 'unverified').toUpperCase(),
                        ),
                        _buildProfileField(
                          context,
                          'Admin Role',
                          currentUser?.adminRole == 'superadmin'
                              ? 'Super Admin'
                              : currentUser?.adminRole == 'admin'
                                  ? 'Admin'
                                  : 'Regular User',
                        ),
                        _buildProfileField(
                          context,
                          'KYC Remarks',
                          currentUser?.kycRemarks ?? 'None',
                        ),
                      ],
                    ),
                  ),
                ),
                if (currentUser?.hasAdminAccess == true) ...[
                  SizedBox(height: spacing.space16),
                  Card(
                    color: theme.colorScheme.surface,
                    child: ListTile(
                      leading: const Icon(Icons.admin_panel_settings, color: Colors.teal),
                      title: const Text('Admin Panel'),
                      subtitle: const Text('Manage KYC reviews and admin access'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.pushNamed(RouteNames.adminPanel),
                    ),
                  ),
                ],
                SizedBox(height: spacing.space24),
                SizedBox(
                  height: 48,
                  width: double.infinity,
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

  Widget _buildProfileField(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final spacing = context.spacing;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.space4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
