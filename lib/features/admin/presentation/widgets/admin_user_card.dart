import 'package:flutter/material.dart';
import 'package:local_first/core/theme/app_theme.dart';
import 'package:local_first/features/auth/domain/entities/user_entity.dart';

class AdminUserCard extends StatelessWidget {
  final UserEntity user;
  final Function(String uid) onGrant;
  final Function(String uid) onRevoke;

  const AdminUserCard({
    super.key,
    required this.user,
    required this.onGrant,
    required this.onRevoke,
  });

  void _showConfirmDialog(BuildContext context, {required bool isGranting}) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isGranting ? 'Grant Admin Access' : 'Revoke Admin Access'),
        content: Text(
          isGranting
              ? 'Are you sure you want to grant admin access for ${user.displayName ?? 'this user'}?'
              : 'Are you sure you want to revoke admin access for ${user.displayName ?? 'this user'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isGranting ? theme.colorScheme.primary : theme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              if (isGranting) {
                onGrant(user.userId);
              } else {
                onRevoke(user.userId);
              }
            },
            child: Text(isGranting ? 'GRANT' : 'REVOKE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    final isSuper = user.isSuperAdmin;
    final isAdmin = user.isAdmin && !isSuper;
    final isRegularUser = !user.isAdmin;

    String roleText = 'User';
    Color badgeColor = Colors.grey;
    if (isSuper) {
      roleText = 'Super Admin';
      badgeColor = Colors.purple;
    } else if (isAdmin) {
      roleText = 'Admin';
      badgeColor = Colors.teal;
    }

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: spacing.edgeMargin,
        vertical: spacing.space8,
      ),
      color: theme.colorScheme.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.space16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: badgeColor.withValues(alpha: 0.1),
              child: Text(
                (user.displayName ?? 'U').substring(0, 1).toUpperCase(),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: badgeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: spacing.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.displayName ?? 'Unknown Name',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: spacing.space8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          roleText,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: badgeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    user.phone,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isSuper) ...[
              // Action is disabled for Super Admins
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.lock, color: Colors.grey),
              ),
            ] else ...[
              // Action to Grant or Revoke
              if (isRegularUser)
                IconButton(
                  icon: const Icon(Icons.person_add_alt_1, color: Colors.teal),
                  onPressed: () => _showConfirmDialog(context, isGranting: true),
                  tooltip: 'Grant Admin Access',
                )
              else
                IconButton(
                  icon: Icon(Icons.remove_circle_outline, color: theme.colorScheme.error),
                  onPressed: () => _showConfirmDialog(context, isGranting: false),
                  tooltip: 'Revoke Admin Access',
                ),
            ],
          ],
        ),
      ),
    );
  }
}
