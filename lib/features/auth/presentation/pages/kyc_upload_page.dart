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
  UserEntity? _user;
  bool _isLoading = true;
  bool _isExistingCleared = false;

  final List<String> _idTypes = const ['Aadhaar', 'Passport', 'Driving License'];

  bool get _canSubmit => _idFile != null;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final authCubit = context.read<AuthCubit>();
    final state = authCubit.state;
    if (state is AuthSuccess) {
      final result = await authCubit.repository.getUser(state.uid);
      if (!mounted) return;
      result.fold(
        (failure) {
          setState(() {
            _isLoading = false;
          });
        },
        (user) {
          setState(() {
            _user = user;
            _isLoading = false;
          });
        },
      );
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickId() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _idFile = File(picked.path));
    }
  }

  void _removeId() {
    setState(() {
      if (_idFile != null) {
        _idFile = null;
      } else {
        _isExistingCleared = true;
      }
    });
  }

  void _onSubmit() {
    if (!_canSubmit) return;
    context.read<AuthCubit>().submitKyc(_idFile!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    String statusText = 'Status: Unverified';
    String messageText = 'Please upload your identity document to start listing items or services.';
    Color statusColor = Colors.grey;

    if (_user != null) {
      final status = _user!.verificationStatus;
      if (status == 'pending') {
        statusText = 'Status: Pending Review';
        messageText = 'Your status is currently pending. Please wait while we review your request. You will be able to list once your identity is verified.';
        statusColor = Colors.orange;
      } else if (status == 'verified') {
        statusText = 'Status: Verified';
        messageText = 'Your identity is verified. You can list items and offer services!';
        statusColor = Colors.green;
      } else if (status == 'rejected') {
        statusText = 'Status: Rejected';
        messageText = 'Your verification request was rejected. Please upload a clear photo of your ID and submit again.';
        statusColor = Colors.red;
      }
    }

    final remoteUrlToShow = _isExistingCleared ? null : _user?.kycDocumentUrl;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is KycSubmitted) {
          _isExistingCleared = false;
          _idFile = null;
          _loadUser();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('KYC details submitted successfully.')),
          );
          if (GoRouter.of(context).canPop()) {
            context.pop();
          } else {
            context.goNamed(RouteNames.home);
          }
        } else if (state is AuthError) {
          ErrorHandler.showSnackBar(context, state.failure);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Identity Verification'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (GoRouter.of(context).canPop()) {
                context.pop();
              } else {
                context.goNamed(RouteNames.home);
              }
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.edgeMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: spacing.space16),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.space8,
                    vertical: spacing.space4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      statusText,
                      style: theme.textTheme.labelSmall?.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: spacing.space16),
                Text(
                  messageText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
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
                  remoteUrl: remoteUrlToShow,
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
  final String? remoteUrl;
  final double width;
  final double height;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _IdUploadCard({
    this.file,
    this.remoteUrl,
    required this.width,
    required this.height,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final hasPreview = file != null || (remoteUrl != null && remoteUrl!.isNotEmpty);

    return Center(
      child: GestureDetector(
        key: !hasPreview ? const Key('kyc_dashed_card') : const Key('kyc_preview'),
        onTap: !hasPreview ? onTap : null,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary,
              style: BorderStyle.solid,
              width: !hasPreview ? 2 : 1,
            ),
          ),
          child: !hasPreview
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
                      child: file != null
                          ? Image.file(file!, fit: BoxFit.cover, width: width, height: height)
                          : Image.network(
                              remoteUrl!,
                              fit: BoxFit.cover,
                              width: width,
                              height: height,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Icon(Icons.broken_image, size: 48),
                              ),
                            ),
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
