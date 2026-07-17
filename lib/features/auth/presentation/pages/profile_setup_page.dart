import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:local_first/core/theme/design_tokens.dart';
import 'package:local_first/features/auth/domain/entities/user_entity.dart';
import 'package:local_first/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:local_first/features/auth/presentation/pages/kyc_upload_page.dart';

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
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const KycUploadPage()),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: DesignTokens.colorBgDark,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.kEdgeMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: DesignTokens.kSpace16),
                Text('Create Profile', style: DesignTokens.h1),
                const SizedBox(height: DesignTokens.kSpace24),
                _AvatarSelector(
                  file: _avatarFile,
                  onTap: _pickAvatar,
                ),
                const SizedBox(height: DesignTokens.kSpace16),
                _NameField(controller: _nameController),
                const SizedBox(height: DesignTokens.kSpace16),
                Text('How do you plan to use this platform?', style: DesignTokens.bodyLarge),
                const SizedBox(height: DesignTokens.kSpace8),
                ..._roleOptions.map((o) => _RoleCard(
                      option: o,
                      checked: _roles[o.key]!,
                      onTap: () => setState(() => _roles[o.key] = !_roles[o.key]!),
                    )),
                const SizedBox(height: DesignTokens.kSpace24),
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
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: DesignTokens.colorSurface,
            border: Border.all(color: DesignTokens.colorPrimary, width: 2),
            image: file != null
                ? DecorationImage(image: FileImage(file!), fit: BoxFit.cover)
                : null,
          ),
          child: file == null
              ? const Icon(Icons.camera_alt, color: DesignTokens.colorPrimary, size: 32)
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
    return Container(
      height: DesignTokens.kTouchMin,
      decoration: BoxDecoration(
        color: DesignTokens.colorSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DesignTokens.colorPrimary),
      ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Full Display Name',
          contentPadding: EdgeInsets.symmetric(horizontal: DesignTokens.kSpace16),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: Key('role_${option.key}'),
        margin: const EdgeInsets.only(bottom: DesignTokens.kSpace8),
        padding: const EdgeInsets.all(DesignTokens.kSpace16),
        decoration: BoxDecoration(
          color: DesignTokens.colorSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: checked ? DesignTokens.colorPrimary : DesignTokens.colorTextMuted,
            width: checked ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              checked ? Icons.check_box : Icons.check_box_outline_blank,
              color: checked ? DesignTokens.colorPrimary : DesignTokens.colorTextMuted,
            ),
            const SizedBox(width: DesignTokens.kSpace8),
            Expanded(child: Text(option.label, style: DesignTokens.bodyLarge)),
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
    return Container(
      padding: const EdgeInsets.only(
        bottom: DesignTokens.kEdgeMargin,
        top: DesignTokens.kSpace16,
      ),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            key: const Key('CREATE ACCOUNT'),
            onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignTokens.colorPrimary,
            disabledBackgroundColor: DesignTokens.colorPrimary.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            label,
            style: DesignTokens.labelBold.copyWith(color: DesignTokens.colorSurface),
          ),
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
