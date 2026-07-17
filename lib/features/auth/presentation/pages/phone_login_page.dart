import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:local_first/core/theme/design_tokens.dart';
import 'package:local_first/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:local_first/features/auth/presentation/pages/otp_verification_page.dart';

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
  final   int _carouselIndex = 0;
  bool _consentChecked = false;
  final PageController _carouselController = PageController(viewportFraction: 0.9);
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
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is OtpSentSuccess) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OtpVerificationPage(phone: _phoneController.text.trim()),
            ),
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
          child: Padding(
            padding: const EdgeInsets.only(top: DesignTokens.kSpace24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DesignTokens.kEdgeMargin),
                  child: _BrandLogo(),
                ),
                const SizedBox(height: DesignTokens.kSpace24),
                _Carousel(
                  valueProps: _valueProps,
                  index: _carouselIndex,
                  controller: _carouselController,
                ),
                const SizedBox(height: DesignTokens.kSpace24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DesignTokens.kEdgeMargin),
                  child: _PhoneField(controller: _phoneController),
                ),
                const SizedBox(height: DesignTokens.kSpace16),
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
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: DesignTokens.colorPrimary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.shield_outlined, color: DesignTokens.colorSurface, size: 20),
        ),
        const SizedBox(width: DesignTokens.kSpace8),
        Text('Local First', style: DesignTokens.titleMedium),
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
    return SizedBox(
      height: 120,
      child: PageView.builder(
        controller: controller,
        itemCount: valueProps.length,
        itemBuilder: (context, i) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: DesignTokens.kSpace8),
            decoration: BoxDecoration(
              color: DesignTokens.colorSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DesignTokens.colorPrimary.withValues(alpha: 0.25)),
            ),
            child: Center(
              child: Text(
                valueProps[i],
                style: DesignTokens.h2.copyWith(color: DesignTokens.colorPrimary),
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
    return Container(
      height: DesignTokens.kTouchMin,
      decoration: BoxDecoration(
        color: DesignTokens.colorSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DesignTokens.colorPrimary),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.kSpace16),
            child: Text('+91', style: DesignTokens.bodyLarge),
          ),
          const VerticalDivider(width: 1, thickness: 1, indent: 8, endIndent: 8),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
                hintText: '10-digit mobile number',
                contentPadding: EdgeInsets.symmetric(horizontal: DesignTokens.kSpace16),
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.kEdgeMargin,
        vertical: DesignTokens.kSpace16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: DesignTokens.kTouchMin,
            height: DesignTokens.kTouchMin,
            child: Checkbox(
              value: checked,
              activeColor: DesignTokens.colorPrimary,
              onChanged: (v) => onChanged(v ?? false),
            ),
          ),
          const SizedBox(width: DesignTokens.kSpace8),
          Expanded(
            child: Text(
              'I accept the terms of service, rental liabilities, and safety guidelines.',
              style: DesignTokens.bodySmall,
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
    return Container(
      padding: const EdgeInsets.all(DesignTokens.kEdgeMargin),
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          key: const Key('GET OTP'),
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignTokens.colorPrimary,
            disabledBackgroundColor: DesignTokens.colorPrimary.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(label, style: DesignTokens.labelBold.copyWith(color: DesignTokens.colorSurface)),
        ),
      ),
    );
  }
}
