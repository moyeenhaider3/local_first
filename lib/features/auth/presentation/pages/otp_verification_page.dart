import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_first/core/router/route_names.dart';
import 'package:local_first/core/theme/app_theme.dart';
import 'package:local_first/features/auth/presentation/cubits/auth_cubit.dart';

/// AUTH feature - Presentation Layer: AUTH-02 OTP Input
/// Row of 6 OTP boxes, resend countdown, [ VERIFY CODE ].
class OtpVerificationPage extends StatefulWidget {
  final String phone;

  const OtpVerificationPage({super.key, required this.phone});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  static const int _codeLength = 6;
  static const int _resendSeconds = 45;

  final List<TextEditingController> _controllers = List.generate(
    _codeLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _codeLength,
    (_) => FocusNode(),
  );
  int _secondsLeft = _resendSeconds;
  bool _showError = false;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft == 0) {
        timer.cancel();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  void _onChanged(int index, String value) {
    if (_showError) setState(() => _showError = false);
    if (value.length == 1 && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    _maybeVerify();
  }

  void _maybeVerify() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length == _codeLength && !_showError) {
      context.read<AuthCubit>().verifyOtp(code);
    }
  }

  String get _maskedPhone {
    final digits = widget.phone;
    final visible = digits.length >= 4
        ? digits.substring(digits.length - 4)
        : digits;
    return '+91 XXXX$visible';
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          if (!state.hasProfile) {
            context.goNamed(RouteNames.profileSetup);
          } else if (!state.hasKyc) {
            context.goNamed(RouteNames.kycUpload);
          } else {
            context.goNamed(RouteNames.home);
          }
        } else if (state is AuthError) {
          setState(() => _showError = true);
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
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: theme.colorScheme.secondary,
                  ),
                  onPressed: () => context.pop(),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.zero,
                ),
                SizedBox(height: spacing.space8),
                Text(
                  'Verification Code',
                  style: theme.textTheme.headlineMedium,
                ),
                SizedBox(height: spacing.space8),
                Text(
                  'We sent a verification code to $_maskedPhone',
                  style: theme.textTheme.bodySmall,
                ),
                SizedBox(height: spacing.space32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    _codeLength,
                    (i) => _otpBox(index: i),
                  ),
                ),
                if (_showError) ...[
                  SizedBox(height: spacing.space8),
                  Text(
                    'Invalid code. Please try again.',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                SizedBox(height: spacing.space8),
                Text(
                  _secondsLeft > 0
                      ? "Didn't receive the code? Resend SMS in ${_secondsLeft}s"
                      : "Didn't receive the code? Tap to resend.",
                  style: theme.textTheme.labelSmall,
                ),
                const Spacer(),
                _StickyVerifyButton(
                  onPressed: _maybeVerify,
                  showError: _showError,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _otpBox({required int index}) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 44,
      height: 52,
      child: TextField(
        key: Key('otp_$index'),
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        onChanged: (v) => _onChanged(index, v),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: _showError
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: _showError
                  ? theme.colorScheme.error
                  : (theme.textTheme.bodySmall?.color ?? Colors.grey),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: _showError
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _StickyVerifyButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool showError;

  const _StickyVerifyButton({required this.onPressed, required this.showError});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Container(
      padding: EdgeInsets.only(
        left: 0,
        right: 0,
        bottom: spacing.edgeMargin,
        top: spacing.space16,
      ),
      child: SizedBox(
        height: 52,
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return ElevatedButton(
              key: const Key('VERIFY CODE'),
              onPressed: !isLoading ? onPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: showError
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
                disabledBackgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
                      'VERIFY CODE',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.surface,
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}
