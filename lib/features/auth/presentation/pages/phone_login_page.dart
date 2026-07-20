import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_first/core/error/error_handler.dart';
import 'package:local_first/core/router/route_names.dart';
import 'package:local_first/core/theme/app_theme.dart';
import 'package:local_first/features/auth/presentation/cubits/auth_cubit.dart';

/// AUTH feature - Presentation Layer: AUTH-01 Welcome & Phone
/// Brand logo, horizontal carousel, mobile field with country code, [ GET OTP ].
class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final List<String> _valueProps = const [
    'Rent nearby',
    'Hire local workers',
    'Verify identity and trust',
  ];
  final int _carouselIndex = 0;
  bool _consentChecked = false;
  final PageController _carouselController = PageController(
    viewportFraction: 0.9,
  );
  Timer? _carouselTimer;

  bool get _isValidPhone =>
      _phoneController.text.trim().length == 10 &&
      RegExp(r'^\d{10}$').hasMatch(_phoneController.text.trim());

  bool get _canSubmit => _isValidPhone && _consentChecked;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() => setState(() {}));
    _startCarousel();
  }

  void _startCarousel() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final next = (_carouselIndex + 1) % _valueProps.length;
      _carouselController.animateToPage(
        next,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _phoneController.dispose();
    _carouselController.dispose();
    super.dispose();
  }

  void _onGetOtp() {
    if (!_canSubmit) return;
    final phone = '+91${_phoneController.text.trim()}';
    context.read<AuthCubit>().verifyPhoneNumber(phone);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is OtpSentSuccess) {
          context.pushNamed(
            RouteNames.otp,
            extra: _phoneController.text.trim(),
          );
        } else if (state is AuthError) {
          ErrorHandler.showSnackBar(context, state.failure);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top: spacing.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.edgeMargin),
                  child: _BrandLogo(),
                ),
                SizedBox(height: spacing.space24),
                _Carousel(
                  valueProps: _valueProps,
                  index: _carouselIndex,
                  controller: _carouselController,
                ),
                SizedBox(height: spacing.space24),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.edgeMargin),
                  child: _PhoneField(controller: _phoneController),
                ),
                SizedBox(height: spacing.space16),
                _ConsentCheckbox(
                  checked: _consentChecked,
                  onChanged: (v) => setState(() => _consentChecked = v),
                ),
                const Spacer(),
                _StickyButton(
                  label: 'GET OTP',
                  enabled: _canSubmit,
                  onPressed: _onGetOtp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.shield_outlined,
            color: theme.colorScheme.surface,
            size: 20,
          ),
        ),
        SizedBox(width: spacing.space8),
        Text('Local First', style: theme.textTheme.titleMedium),
      ],
    );
  }
}

class _Carousel extends StatelessWidget {
  final List<String> valueProps;
  final int index;
  final PageController controller;

  const _Carousel({
    required this.valueProps,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return SizedBox(
      height: 120,
      child: PageView.builder(
        controller: controller,
        itemCount: valueProps.length,
        itemBuilder: (context, i) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: spacing.space8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Center(
              child: Text(
                valueProps[i],
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;

  const _PhoneField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Container(
      height: 48.0,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: theme.colorScheme.primary),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.space16),
            child: Text('+91', style: theme.textTheme.bodyLarge),
          ),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            indent: 8,
            endIndent: 8,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                counterText: '',
                hintText: '10-digit mobile number',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: spacing.space16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsentCheckbox extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool> onChanged;

  const _ConsentCheckbox({required this.checked, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.edgeMargin,
        vertical: spacing.space16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48.0,
            height: 48.0,
            child: Checkbox(
              value: checked,
              activeColor: theme.colorScheme.primary,
              onChanged: (v) => onChanged(v ?? false),
            ),
          ),
          SizedBox(width: spacing.space8),
          Expanded(
            child: Text(
              'I accept the terms of service, rental liabilities, and safety guidelines.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
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
      padding: EdgeInsets.all(spacing.edgeMargin),
      child: SizedBox(
        height: 52,
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return ElevatedButton(
              key: const Key('GET OTP'),
              onPressed: (enabled && !isLoading) ? onPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
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
                      label,
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
