import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_first/core/di/service_locator.dart';
import 'package:local_first/core/theme/design_tokens.dart';
import 'package:local_first/features/verification/presentation/cubits/verification_cubit.dart';
import 'package:local_first/features/verification/presentation/cubits/verification_state.dart';
import 'package:local_first/features/verification/presentation/widgets/code_input_widget.dart';

/// A bottom sheet for verifying physical handover and condition via a pickup code.
///
/// Features warning notifications, condition checklists, code inputs, and state
/// bindings to the [VerificationCubit].
class PickupCodeBottomSheet extends StatefulWidget {
  /// The unique ID of the verification task.
  final String taskId;

  /// Creates a [PickupCodeBottomSheet].
  const PickupCodeBottomSheet({
    super.key,
    required this.taskId,
  });

  /// Displays the pickup code bottom sheet.
  static Future<bool?> show(BuildContext context, String taskId) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PickupCodeBottomSheet(taskId: taskId),
    );
  }

  @override
  State<PickupCodeBottomSheet> createState() => _PickupCodeBottomSheetState();
}

class _PickupCodeBottomSheetState extends State<PickupCodeBottomSheet> {
  /// Global key to access the [CodeInputWidgetState] for triggering error and success animations.
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
                      content: Text('Handover verification completed successfully.'),
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
                '1. Item Handover Verification',
                style: DesignTokens.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignTokens.kSpace16),
              Container(
                padding: const EdgeInsets.all(DesignTokens.kSpace16),
                decoration: BoxDecoration(
                  color: DesignTokens.colorWarning,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  "INSPECT FIRST: Inspect the item's condition. Enter the owner's Pickup Code only after you have verified the item is in working condition.",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.kSpace16),
              Text(
                'I inspected the item and its listed accessories. I accept the recorded handover condition, including the disclosed defects. Entering the pickup code records my acknowledgment that I received the item in this condition.',
                style: DesignTokens.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                  color: DesignTokens.colorTextMuted,
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
              const SizedBox(height: DesignTokens.kSpace24),
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
                              'VERIFY HANDOVER & CONDITION',
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
