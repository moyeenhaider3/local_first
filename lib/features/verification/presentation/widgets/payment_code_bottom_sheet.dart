import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_first/core/di/service_locator.dart';
import 'package:local_first/core/theme/design_tokens.dart';
import 'package:local_first/features/payments/presentation/cubits/payment_cubit.dart';
import 'package:local_first/features/verification/presentation/cubits/verification_cubit.dart';
import 'package:local_first/features/verification/presentation/cubits/verification_state.dart';
import 'package:local_first/features/verification/presentation/widgets/code_input_widget.dart';

/// A bottom sheet for verifying external UPI payments via a payment settlement code.
///
/// Upgraded with Amount Paid input, Remarks input, and Payment Proof screenshot upload.
class PaymentCodeBottomSheet extends StatefulWidget {
  /// The unique ID of the verification task.
  final String taskId;

  /// The declared amount for settlement.
  final double declaredAmount;

  /// The name of the payee counterparty.
  final String counterpartyName;

  /// Optional agreement ID associated with payment escrow.
  final String? agreementId;

  /// Creates a [PaymentCodeBottomSheet].
  const PaymentCodeBottomSheet({
    super.key,
    required this.taskId,
    required this.declaredAmount,
    required this.counterpartyName,
    this.agreementId,
  });

  /// Displays the payment code bottom sheet.
  static Future<bool?> show({
    required BuildContext context,
    required String taskId,
    required double declaredAmount,
    required String counterpartyName,
    String? agreementId,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentCodeBottomSheet(
        taskId: taskId,
        declaredAmount: declaredAmount,
        counterpartyName: counterpartyName,
        agreementId: agreementId,
      ),
    );
  }

  @override
  State<PaymentCodeBottomSheet> createState() => _PaymentCodeBottomSheetState();
}

class _PaymentCodeBottomSheetState extends State<PaymentCodeBottomSheet> {
  /// Global key to access [CodeInputWidgetState] for error and success transitions.
  final GlobalKey<CodeInputWidgetState> _codeInputKey =
      GlobalKey<CodeInputWidgetState>();

  /// Text editing controller for the Amount Paid input field.
  late final TextEditingController _amountPaidController;

  /// Text editing controller for the Remarks input field.
  final TextEditingController _remarksController = TextEditingController();

  /// Selected payment proof image file.
  File? _proofImageFile;

  /// The currently entered 4-digit code.
  String _enteredCode = '';

  /// Tracks uploading or submission state.
  bool _isUploadingProof = false;

  @override
  void initState() {
    super.initState();
    _amountPaidController = TextEditingController(
      text: widget.declaredAmount.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _amountPaidController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  /// Picks a payment proof screenshot from gallery or camera.
  Future<void> _pickProofImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _proofImageFile = File(picked.path);
      });
    }
  }

  /// Removes the selected payment proof image.
  void _removeProofImage() {
    setState(() {
      _proofImageFile = null;
    });
  }

  /// Handles verification submission including uploading proof if provided.
  Future<void> _handleVerifySubmission(BuildContext context) async {
    final amountText = _amountPaidController.text.trim();
    final amountPaid = double.tryParse(amountText) ?? widget.declaredAmount;
    final remarks = _remarksController.text.trim();

    if (widget.agreementId != null && _proofImageFile != null) {
      setState(() {
        _isUploadingProof = true;
      });
      final paymentCubit = sl<PaymentCubit>();
      await paymentCubit.holdPaymentInEscrow(
        agreementId: widget.agreementId!,
        totalAmount: widget.declaredAmount,
        amountPaid: amountPaid,
        remarks: remarks.isNotEmpty ? remarks : 'Payment verified via settlement code',
        localImagePath: _proofImageFile!.path,
        paymentMethod: 'UPI',
      );
      if (mounted) {
        setState(() {
          _isUploadingProof = false;
        });
      }
    }

    if (context.mounted) {
      context.read<VerificationCubit>().submitVerificationCode(
            widget.taskId,
            _enteredCode,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VerificationCubit>(
      create: (context) => sl<VerificationCubit>()..watchTask(widget.taskId),
      child: Container(
        decoration: const BoxDecoration(
          color: DesignTokens.colorSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        padding: EdgeInsets.only(
          left: DesignTokens.kEdgeMargin,
          right: DesignTokens.kEdgeMargin,
          top: DesignTokens.kSpace8,
          bottom: MediaQuery.of(context).viewInsets.bottom + DesignTokens.kSpace24,
        ),
        child: BlocListener<VerificationCubit, VerificationState>(
          listener: (context, state) {
            if (state is CodeVerificationSuccess) {
              _codeInputKey.currentState?.triggerSuccess();
              Future.delayed(const Duration(milliseconds: 600), () {
                if (context.mounted) {
                  Navigator.of(context).pop(true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment verification completed successfully.'),
                      backgroundColor: DesignTokens.colorSuccess,
                    ),
                  );
                }
              });
            } else if (state is CodeVerificationFailure) {
              _codeInputKey.currentState?.triggerError();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${state.message} (${state.attemptsRemaining} attempts remaining)',
                  ),
                  backgroundColor: DesignTokens.colorDanger,
                ),
              );
            } else if (state is VerificationError) {
              _codeInputKey.currentState?.triggerError();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: DesignTokens.colorDanger,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40.0,
                    height: 4.0,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.kSpace8),
                Text(
                  '2. Payment Settlement Code',
                  style: DesignTokens.h2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: DesignTokens.kSpace16),
                Text(
                  'Confirm UPI payment of ₹${widget.declaredAmount.toStringAsFixed(2)} to ${widget.counterpartyName}',
                  style: DesignTokens.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.colorTextMain,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: DesignTokens.kSpace24),

                // Amount Paid Field
                TextFormField(
                  controller: _amountPaidController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount Paid (₹)',
                    hintText: 'Enter amount paid',
                    prefixIcon: const Icon(Icons.currency_rupee, color: DesignTokens.colorPrimary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: DesignTokens.colorPrimary,
                        width: 2.0,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(12.0),
                  ),
                ),
                const SizedBox(height: DesignTokens.kSpace16),

                // Transaction Remarks Field
                TextFormField(
                  controller: _remarksController,
                  decoration: InputDecoration(
                    labelText: 'Remarks / Transaction Ref ID (Optional)',
                    hintText: 'e.g. UPI Ref #1234567890',
                    prefixIcon: const Icon(Icons.notes_outlined, color: DesignTokens.colorTextMuted),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: DesignTokens.colorPrimary,
                        width: 2.0,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(12.0),
                  ),
                ),
                const SizedBox(height: DesignTokens.kSpace16),

                // Payment Proof Screenshot Selector Widget
                Text(
                  'Payment Proof Screenshot',
                  style: DesignTokens.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.colorTextMuted,
                  ),
                ),
                const SizedBox(height: DesignTokens.kSpace8),
                GestureDetector(
                  onTap: _pickProofImage,
                  child: Container(
                    height: 100.0,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: const Color(0xFFCBD5E1),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: _proofImageFile != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.file(
                                  _proofImageFile!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 100.0,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: _removeProofImage,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4.0),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_photo_alternate_outlined,
                                color: DesignTokens.colorPrimary,
                                size: 28.0,
                              ),
                              const SizedBox(height: DesignTokens.kSpace4),
                              Text(
                                'Tap to upload UPI payment receipt screenshot',
                                style: DesignTokens.bodySmall.copyWith(
                                  color: DesignTokens.colorTextMuted,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: DesignTokens.kSpace24),

                // Code Input Widget (4-digit settlement code)
                CodeInputWidget(
                  key: _codeInputKey,
                  onChanged: (code) {
                    setState(() {
                      _enteredCode = code;
                    });
                  },
                  onCompleted: (code) {
                    // Auto-fill completed code
                  },
                ),
                const SizedBox(height: DesignTokens.kSpace32),

                // Verify Action Button
                Builder(
                  builder: (context) {
                    final state = context.watch<VerificationCubit>().state;
                    final isLoading = state is CodeSubmitting || _isUploadingProof;

                    return SizedBox(
                      height: 52.0,
                      child: ElevatedButton(
                        onPressed: _enteredCode.length == 4 && !isLoading
                            ? () => _handleVerifySubmission(context)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesignTokens.colorPrimary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24.0,
                                height: 24.0,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.0,
                                ),
                              )
                            : const Text(
                                'VERIFY PAYMENT SETTLEMENT',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
