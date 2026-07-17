import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_first/core/router/route_names.dart';
import 'package:local_first/core/theme/app_theme.dart';
import 'package:local_first/features/auth/domain/entities/user_entity.dart';
import 'package:local_first/features/auth/presentation/cubits/auth_cubit.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    // Read current user profile to check super admin status
    final authState = context.read<AuthCubit>().state;
    UserEntity? currentUser;
    if (authState is AuthSuccess) {
      currentUser = authState.userEntity;
    }

    final isSuper = currentUser?.isSuperAdmin ?? false;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.edgeMargin,
            vertical: spacing.space16,
          ),
          children: [
            // Admin Welcome Header
            Text(
              'Welcome back, ${currentUser?.displayName ?? 'Admin'}',
              style: theme.textTheme.headlineMedium,
            ),
            SizedBox(height: spacing.space8),
            Text(
              'Select an administration console below to manage the platform.',
              style: theme.textTheme.bodySmall,
            ),
            SizedBox(height: spacing.space24),

            // Card 1: KYC Review
            _buildDashboardCard(
              context,
              title: 'KYC Reviews',
              description: 'Review pending identity verifications and document submissions.',
              icon: Icons.verified_user,
              color: Colors.teal,
              onTap: () => context.pushNamed(RouteNames.adminKycReview),
            ),

            if (isSuper) ...[
              SizedBox(height: spacing.space16),
              // Card 2: User Management
              _buildDashboardCard(
                context,
                title: 'Manage Admins',
                description: 'Search users and grant or revoke administrative roles.',
                icon: Icons.admin_panel_settings,
                color: Colors.purple,
                onTap: () => context.pushNamed(RouteNames.adminUserManagement),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Card(
      color: theme.colorScheme.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(spacing.space24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(spacing.space8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              SizedBox(width: spacing.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: spacing.space4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
