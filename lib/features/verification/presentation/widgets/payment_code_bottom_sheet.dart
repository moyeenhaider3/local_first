import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_first/core/di/service_locator.dart';
import 'package:local_first/core/theme/design_tokens.dart';
import 'package:local_first/features/verification/presentation/cubits/verification_cubit.dart';
import 'package:local_first/features/verification/presentation/cubits/verification_state.dart';
import 'package:local_first/features/verification/presentation/widgets/code_input_widget.dart';

/// A bottom sheet for verifying external UPI payments via a payment settlement code.
///
/// Features transaction details display, code inputs, and state bindings to [VerificationCubit].
class PaymentCodeBottomSheet extends StatefulWidget {
  /// The unique ID of the verification task.
  final String taskId;

  /// The declared amount for settlement.
  final double declaredAmount;

  /// The name of the payee counterparty.
  final String counterpartyName;

  /// Creates a [PaymentCodeBottomSheet].
  const PaymentCodeBottomSheet({
    super.key,
    required this.taskId,
    required this.declaredAmount,
    required this.counterpartyName,
  });

  /// Displays the payment code bottom sheet.
  static Future<bool?> show({
    required BuildContext context,
    required String taskId,
    required double declaredAmount,
    required String counterpartyName,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentCodeBottomSheet(
        taskId: taskId,
        declaredAmount: declaredAmount,
        counterpartyName: counterpartyName,
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

  /// The currently entered 4-digit code.
  String _enteredCode = '';

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
              const SizedBox(height: DesignTokens.kSpace24),
              Text(
                'Confirm UPI payment of ₹${widget.declaredAmount.toStringAsFixed(2)} to ${widget.counterpartyName}',
                style: DesignTokens.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.colorTextMain,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignTokens.kSpace24),
              CodeInputWidget(
                key: _codeInputKey,
                onChanged: (code) {
                  setState(() {
                    _enteredCode = code;
                  });
                },
                onCompleted: (code) {
                  // Auto-submit once code is fully typed.
                },
              ),
              const SizedBox(height: DesignTokens.kSpace32),
              Builder(
                builder: (context) {
                  final state = context.watch<VerificationCubit>().state;
                  final isLoading = state is CodeSubmitting;

                  return SizedBox(
                    height: 52.0,
                    child: ElevatedButton(
                      onPressed: _enteredCode.length == 4 && !isLoading
                          ? () {
                              context
                                  .read<VerificationCubit>()
                                  .submitVerificationCode(
                                    widget.taskId,
                                    _enteredCode,
                                  );
                            }
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
    );
  }
}
