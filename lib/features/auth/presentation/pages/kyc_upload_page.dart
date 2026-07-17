import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:local_first/core/theme/design_tokens.dart';
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
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is KycSubmitted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: DesignTokens.colorBgDark,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.kEdgeMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: DesignTokens.kSpace16),
                Text('Identity Verification', style: DesignTokens.h2),
                const SizedBox(height: DesignTokens.kSpace8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.kSpace8,
                    vertical: DesignTokens.kSpace4,
                  ),
                  decoration: BoxDecoration(
                    color: DesignTokens.colorTextMuted.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Status: Unverified',
                    style: DesignTokens.caption,
                  ),
                ),
                const SizedBox(height: DesignTokens.kSpace24),
                _IdTypeDropdown(
                  value: _idType,
                  options: _idTypes,
                  onChanged: (v) => setState(() => _idType = v),
                ),
                const SizedBox(height: DesignTokens.kSpace24),
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
    return Container(
      height: DesignTokens.kTouchMin,
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.kSpace16),
      decoration: BoxDecoration(
        color: DesignTokens.colorSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DesignTokens.colorPrimary),
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
    return Center(
      child: GestureDetector(
        key: file == null ? const Key('kyc_dashed_card') : const Key('kyc_preview'),
        onTap: file == null ? onTap : null,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: DesignTokens.colorSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: DesignTokens.colorPrimary,
              style: BorderStyle.solid,
              width: file == null ? 2 : 1,
            ),
          ),
          child: file == null
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, color: DesignTokens.colorPrimary, size: 32),
                    SizedBox(height: DesignTokens.kSpace8),
                    Text(
                      'Tap to photograph front of ID',
                      style: DesignTokens.bodySmall,
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
                      top: DesignTokens.kSpace8,
                      right: DesignTokens.kSpace8,
                      child: GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: DesignTokens.colorDanger,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(DesignTokens.kSpace4),
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
    return Container(
      padding: const EdgeInsets.only(
        bottom: DesignTokens.kEdgeMargin,
        top: DesignTokens.kSpace16,
      ),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            key: const Key('SUBMIT KYC DETAILS'),
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
