import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:local_first/core/error/error_handler.dart';
import 'package:local_first/core/router/route_names.dart';
import 'package:local_first/core/theme/app_theme.dart';
import 'package:local_first/features/auth/presentation/cubits/auth_cubit.dart';

/// AUTH feature - Presentation Layer: AUTH-04 KYC Upload
/// ID dropdown, dashed upload card, [ SUBMIT KYC DETAILS ].
class KycUploadPage extends StatefulWidget {
  const KycUploadPage({super.key});

  @override
  State<KycUploadPage> createState() => _KycUploadPageState();
}

class _KycUploadPageState extends State<KycUploadPage> {
  static const double _cardWidth = 328;
  static const double _cardHeight = 160;

  String _idType = 'Aadhaar';
  File? _idFile;

  final List<String> _idTypes = const ['Aadhaar', 'Passport', 'Driving License'];

  bool get _canSubmit => _idFile != null;

  Future<void> _pickId() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _idFile = File(picked.path));
    }
  }

  void _removeId() => setState(() => _idFile = null);

  void _onSubmit() {
    if (!_canSubmit) return;
    context.read<AuthCubit>().submitKyc(_idFile!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final mutedColor = theme.textTheme.bodySmall?.color ?? Colors.grey;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is KycSubmitted) {
          context.goNamed(RouteNames.home);
        } else if (state is AuthError) {
          ErrorHandler.showSnackBar(context, state.failure);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.edgeMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: spacing.space16),
                Text('Identity Verification', style: theme.textTheme.headlineMedium),
                SizedBox(height: spacing.space8),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.space8,
                    vertical: spacing.space4,
                  ),
                  decoration: BoxDecoration(
                    color: mutedColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Status: Unverified',
                    style: theme.textTheme.labelSmall,
                  ),
                ),
                SizedBox(height: spacing.space24),
                _IdTypeDropdown(
                  value: _idType,
                  options: _idTypes,
                  onChanged: (v) => setState(() => _idType = v),
                ),
                SizedBox(height: spacing.space24),
                _IdUploadCard(
                  file: _idFile,
                  width: _cardWidth,
                  height: _cardHeight,
                  onTap: _pickId,
                  onRemove: _removeId,
                ),
                const Spacer(),
                _StickyButton(
                  label: 'SUBMIT KYC DETAILS',
                  enabled: _canSubmit,
                  onPressed: _onSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IdTypeDropdown extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _IdTypeDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Container(
      height: 48.0,
      padding: EdgeInsets.symmetric(horizontal: spacing.space16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.primary),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: options
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ),
    );
  }
}

class _IdUploadCard extends StatelessWidget {
  final File? file;
  final double width;
  final double height;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _IdUploadCard({
    this.file,
    required this.width,
    required this.height,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Center(
      child: GestureDetector(
        key: file == null ? const Key('kyc_dashed_card') : const Key('kyc_preview'),
        onTap: file == null ? onTap : null,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary,
              style: BorderStyle.solid,
              width: file == null ? 2 : 1,
            ),
          ),
          child: file == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, color: theme.colorScheme.primary, size: 32),
                    SizedBox(height: spacing.space8),
                    Text(
                      'Tap to photograph front of ID',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                )
              : Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(file!, fit: BoxFit.cover, width: width, height: height),
                    ),
                    Positioned(
                      top: spacing.space8,
                      right: spacing.space8,
                      child: GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(spacing.space4),
                          child: const Icon(Icons.close, color: Colors.white, size: 16),
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
              key: const Key('SUBMIT KYC DETAILS'),
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
