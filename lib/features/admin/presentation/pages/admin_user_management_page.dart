import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_first/core/theme/app_theme.dart';
import 'package:local_first/features/admin/presentation/cubits/admin_users_cubit.dart';
import 'package:local_first/features/admin/presentation/cubits/admin_users_state.dart';
import 'package:local_first/features/admin/presentation/widgets/admin_user_card.dart';
import 'package:local_first/features/auth/presentation/cubits/auth_cubit.dart';

class AdminUserManagementPage extends StatefulWidget {
  const AdminUserManagementPage({super.key});

  @override
  State<AdminUserManagementPage> createState() => _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    context.read<AdminUsersCubit>().loadAdminUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
    context.read<AdminUsersCubit>().loadAdminUsers();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    // Check if the current user is Super Admin
    final authState = context.read<AuthCubit>().state;
    bool isSuperAdmin = false;
    if (authState is AuthSuccess) {
      isSuperAdmin = authState.userEntity?.isSuperAdmin ?? false;
    }

    if (!isSuperAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Unauthorized')),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(spacing.edgeMargin),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.gpp_bad, size: 64, color: theme.colorScheme.error),
                SizedBox(height: spacing.space16),
                Text(
                  'Access Denied',
                  style: theme.textTheme.headlineMedium,
                ),
                SizedBox(height: spacing.space8),
                const Text(
                  'You must be a Super Admin to access this page.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                decoration: const InputDecoration(
                  hintText: 'Search users...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                ),
                autofocus: true,
                onChanged: (query) {
                  context.read<AdminUsersCubit>().searchUsers(query);
                },
              )
            : const Text('Manage Admins'),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _stopSearch,
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _startSearch,
            ),
        ],
      ),
      body: BlocListener<AdminUsersCubit, AdminUsersState>(
        listener: (context, state) {
          if (state is AdminUsersUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AdminUsersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        child: BlocBuilder<AdminUsersCubit, AdminUsersState>(
          builder: (context, state) {
            if (state is AdminUsersLoading || state is AdminUsersUpdating) {
              return const Center(child: CircularProgressIndicator());
            }

            List<dynamic> usersToDisplay = [];
            bool isSearchResults = false;

            if (state is AdminUsersLoaded) {
              usersToDisplay = state.adminUsers;
            } else if (state is AdminUsersSearchResults) {
              usersToDisplay = state.results;
              isSearchResults = true;
            }

            if (state is AdminUsersError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(spacing.edgeMargin),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                      SizedBox(height: spacing.space16),
                      Text(state.message, textAlign: TextAlign.center),
                      SizedBox(height: spacing.space16),
                      ElevatedButton(
                        onPressed: () {
                          if (_isSearching && _searchController.text.isNotEmpty) {
                            context.read<AdminUsersCubit>().searchUsers(_searchController.text);
                          } else {
                            context.read<AdminUsersCubit>().loadAdminUsers();
                          }
                        },
                        child: const Text('RETRY'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (usersToDisplay.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(spacing.edgeMargin),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.group_outlined,
                        size: 64,
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                      SizedBox(height: spacing.space16),
                      Text(
                        isSearchResults ? 'No Users Found' : 'No Admin Users',
                        style: theme.textTheme.titleMedium,
                      ),
                      SizedBox(height: spacing.space8),
                      Text(
                        isSearchResults
                            ? 'Try a different search query.'
                            : 'No other administrative users registered.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: spacing.space8),
              itemCount: usersToDisplay.length,
              itemBuilder: (context, index) {
                final user = usersToDisplay[index];
                return AdminUserCard(
                  user: user,
                  onGrant: (uid) {
                    context.read<AdminUsersCubit>().grantAdmin(uid);
                  },
                  onRevoke: (uid) {
                    context.read<AdminUsersCubit>().revokeAdmin(uid);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
