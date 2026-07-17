import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:local_first/core/error/error_handler.dart';
import 'package:local_first/core/router/route_names.dart';
import 'package:local_first/core/theme/app_theme.dart';
import 'package:local_first/features/auth/domain/entities/user_entity.dart';
import 'package:local_first/features/auth/presentation/cubits/auth_cubit.dart';

/// AUTH feature - Presentation Layer: AUTH-03 Profile Setup
/// Circular avatar, name input, role checklist cards, [ CREATE ACCOUNT ].
class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final TextEditingController _nameController = TextEditingController();
  final Map<String, bool> _roles = {
    'renter': false,
    'owner': false,
    'customer': false,
    'worker': false,
  };
  File? _avatarFile;

  static const List<_RoleOption> _roleOptions = [
    _RoleOption(key: 'renter', label: 'I want to rent items from neighbors'),
    _RoleOption(key: 'owner', label: 'I want to rent out my items to others'),
    _RoleOption(key: 'customer', label: 'I want to hire local service workers'),
    _RoleOption(key: 'worker', label: 'I want to list my skills as a service worker'),
  ];

  bool get _canSubmit =>
      _nameController.text.trim().isNotEmpty &&
      _roles.values.any((v) => v);

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _avatarFile = File(picked.path));
    }
  }

  void _onCreateAccount() {
    if (!_canSubmit) return;
    final cubit = context.read<AuthCubit>();
    cubit.createProfile(
      UserEntity(
        userId: '',
        phone: '',
        displayName: _nameController.text.trim(),
        photoUrl: _avatarFile?.path,
        roles: Map.from(_roles),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.goNamed(RouteNames.home);
        } else if (state is AuthError) {
          ErrorHandler.showSnackBar(context, state.failure);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: spacing.edgeMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: spacing.space16),
                Text('Create Profile', style: theme.textTheme.displayLarge),
                SizedBox(height: spacing.space24),
                _AvatarSelector(
                  file: _avatarFile,
                  onTap: _pickAvatar,
                ),
                SizedBox(height: spacing.space16),
                _NameField(controller: _nameController),
                SizedBox(height: spacing.space16),
                Text('How do you plan to use this platform?', style: theme.textTheme.bodyLarge),
                SizedBox(height: spacing.space8),
                ..._roleOptions.map((o) => _RoleCard(
                      option: o,
                      checked: _roles[o.key]!,
                      onTap: () => setState(() => _roles[o.key] = !_roles[o.key]!),
                    )),
                SizedBox(height: spacing.space24),
                _StickyButton(
                  label: 'CREATE ACCOUNT',
                  enabled: _canSubmit,
                  onPressed: _onCreateAccount,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarSelector extends StatelessWidget {
  final File? file;
  final VoidCallback onTap;

  const _AvatarSelector({this.file, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.surface,
            border: Border.all(color: theme.colorScheme.primary, width: 2),
            image: file != null
                ? DecorationImage(image: FileImage(file!), fit: BoxFit.cover)
                : null,
          ),
          child: file == null
              ? Icon(Icons.camera_alt, color: theme.colorScheme.primary, size: 32)
              : null,
        ),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  final TextEditingController controller;

  const _NameField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Container(
      height: 48.0,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.primary),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: 'Full Display Name',
          contentPadding: EdgeInsets.symmetric(horizontal: spacing.space16),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final _RoleOption option;
  final bool checked;
  final VoidCallback onTap;

  const _RoleCard({
    required this.option,
    required this.checked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final mutedColor = theme.textTheme.bodySmall?.color ?? Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: Key('role_${option.key}'),
        margin: EdgeInsets.only(bottom: spacing.space8),
        padding: EdgeInsets.all(spacing.space16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: checked ? theme.colorScheme.primary : mutedColor,
            width: checked ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              checked ? Icons.check_box : Icons.check_box_outline_blank,
              color: checked ? theme.colorScheme.primary : mutedColor,
            ),
            SizedBox(width: spacing.space8),
            Expanded(child: Text(option.label, style: theme.textTheme.bodyLarge)),
          ],
        ),
      ),
    );
  }
}

class _StickyButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  const _StickyButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Container(
      padding: EdgeInsets.only(
        bottom: spacing.edgeMargin,
        top: spacing.space16,
      ),
      child: SizedBox(
        height: 52,
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return ElevatedButton(
              key: const Key('CREATE ACCOUNT'),
              onPressed: (enabled && !isLoading) ? onPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                disabledBackgroundColor: theme.colorScheme.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.surface,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.surface),
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _RoleOption {
  final String key;
  final String label;

  const _RoleOption({required this.key, required this.label});
}
