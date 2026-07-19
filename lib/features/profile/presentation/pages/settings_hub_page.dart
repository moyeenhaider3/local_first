import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_first/core/router/route_names.dart';
import 'package:local_first/core/theme/design_tokens.dart';
import 'package:local_first/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:local_first/features/profile/presentation/cubits/profile_hub_cubit.dart';
import 'package:local_first/features/profile/presentation/cubits/profile_hub_state.dart';
import 'package:local_first/features/profile/presentation/widgets/support_ticket_bottom_sheet.dart';

/// PROFILE feature - Presentation Layer: Settings Hub Page (PROF-01)
/// User profile settings, trust summary card, conditional Admin Panel navigation,
/// support ticket creation entry, and auth session sign-out in Local First.
class SettingsHubPage extends StatefulWidget {
  /// Creates a [SettingsHubPage] instance.
  const SettingsHubPage({super.key});

  @override
  State<SettingsHubPage> createState() => _SettingsHubPageState();
}

class _SettingsHubPageState extends State<SettingsHubPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      context.read<ProfileHubCubit>().loadProfileData(authState.uid);
    }
  }

  /// Opens the [SupportTicketBottomSheet] modal form.
  void _openSupportTicketModal(BuildContext context, String userId, String userName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: context.read<ProfileHubCubit>(),
        child: SupportTicketBottomSheet(
          userId: userId,
          userName: userName,
        ),
      ),
    );
  }

  /// Prompts user confirmation dialog before signing out of Local First session.
  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out of Local First?'),
        content: const Text('Are you sure you want to log out of your Local First account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.colorDanger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthCubit>().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.colorBgDark,
      appBar: AppBar(
        title: const Text(
          'Settings & Profile',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: DesignTokens.colorTextMain,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          final userEntity = authState is AuthSuccess ? authState.userEntity : null;
          final userId = authState is AuthSuccess ? authState.uid : '';
          final displayName = userEntity?.displayName ?? 'Local First User';
          final phone = userEntity?.phone ?? '';
          final isVerified = userEntity?.verificationStatus == 'verified';
          final hasAdminAccess = userEntity?.hasAdminAccess ?? false;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(DesignTokens.kSpace16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Header Card
                Container(
                  padding: const EdgeInsets.all(DesignTokens.kSpace16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: DesignTokens.colorPrimary.withValues(alpha: 0.1),
                        backgroundImage: (userEntity?.photoUrl != null && userEntity!.photoUrl!.isNotEmpty)
                            ? NetworkImage(userEntity.photoUrl!) as ImageProvider
                            : null,
                        child: (userEntity?.photoUrl == null || userEntity!.photoUrl!.isEmpty)
                            ? Text(
                                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: DesignTokens.colorPrimary,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: DesignTokens.kSpace16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: DesignTokens.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              phone.isNotEmpty ? phone : 'Phone unverified',
                              style: DesignTokens.bodySmall,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isVerified
                                    ? DesignTokens.colorSuccess.withValues(alpha: 0.12)
                                    : DesignTokens.colorWarning.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isVerified ? Icons.verified : Icons.error_outline,
                                    size: 14,
                                    color: isVerified ? DesignTokens.colorSuccess : DesignTokens.colorWarning,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isVerified ? 'Verified Citizen' : 'Verification Pending',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isVerified ? DesignTokens.colorSuccess : DesignTokens.colorWarning,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DesignTokens.kSpace16),

                // Trust Score Summary Banner
                BlocBuilder<ProfileHubCubit, ProfileHubState>(
                  builder: (context, profileState) {
                    final trustScore = profileState is ProfileHubLoaded ? profileState.trustScore : 85;

                    return Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => context.pushNamed(RouteNames.trustProfile),
                          child: Padding(
                            padding: const EdgeInsets.all(DesignTokens.kSpace24),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: DesignTokens.colorPrimary.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.shield_rounded,
                                    color: Colors.tealAccent,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: DesignTokens.kSpace16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'Trust Score: ',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            '$trustScore / 100',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.tealAccent,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'View full trust breakdown & peer review feed',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white70,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: DesignTokens.kSpace24),

                // CONDITIONAL ADMIN PANEL NAVIGATION SECTION
                if (hasAdminAccess) ...[
                  const Text(
                    'ADMINISTRATION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: DesignTokens.colorTextMuted,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.kSpace8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: DesignTokens.colorDanger.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings,
                          color: DesignTokens.colorDanger,
                        ),
                      ),
                      title: const Text(
                        'Admin Control Center',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: DesignTokens.colorDanger,
                        ),
                      ),
                      subtitle: const Text(
                        'KYC verification, user moderation & platform settings',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: DesignTokens.colorDanger,
                      ),
                      onTap: () => context.pushNamed(RouteNames.adminPanel),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.kSpace24),
                ],

                // ACCOUNT & SECURITY SECTION
                const Text(
                  'ACCOUNT & PREFERENCES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: DesignTokens.colorTextMuted,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: DesignTokens.kSpace8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person_outline, color: DesignTokens.colorTextMain),
                        title: const Text('Edit Profile Details'),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () => context.pushNamed(RouteNames.profileSetup),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.verified_user_outlined, color: DesignTokens.colorTextMain),
                        title: const Text('Identity Verification (KYC)'),
                        subtitle: Text(
                          isVerified ? 'Status: Verified' : 'Status: Upload Documents',
                          style: TextStyle(
                            fontSize: 12,
                            color: isVerified ? DesignTokens.colorSuccess : DesignTokens.colorWarning,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () => context.pushNamed(RouteNames.kycUpload),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DesignTokens.kSpace24),

                // HELP & SUPPORT SECTION
                const Text(
                  'HELP & COMMUNITY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: DesignTokens.colorTextMuted,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: DesignTokens.kSpace8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.support_agent_outlined, color: DesignTokens.colorTextMain),
                        title: const Text('Create Support Ticket'),
                        subtitle: const Text('Report an issue or dispute to Local First team'),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () => _openSupportTicketModal(context, userId, displayName),
                      ),
                      const Divider(height: 1),
                      const ListTile(
                        leading: Icon(Icons.info_outline, color: DesignTokens.colorTextMain),
                        title: Text('About Local First'),
                        subtitle: Text('Version 1.0.0 • Hyperlocal Civic Community Platform'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DesignTokens.kSpace32),

                // LOGOUT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: DesignTokens.kTouchMin,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DesignTokens.colorDanger,
                      side: const BorderSide(color: DesignTokens.colorDanger, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text(
                      'Log Out of Local First',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () => _confirmSignOut(context),
                  ),
                ),
                const SizedBox(height: DesignTokens.kSpace32),
              ],
            ),
          );
        },
      ),
    );
  }
}
