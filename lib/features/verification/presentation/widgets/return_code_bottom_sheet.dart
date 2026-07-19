import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_first/core/di/service_locator.dart';
import 'package:local_first/core/theme/design_tokens.dart';
import 'package:local_first/features/verification/presentation/cubits/verification_cubit.dart';
import 'package:local_first/features/verification/presentation/cubits/verification_state.dart';
import 'package:local_first/features/verification/presentation/widgets/code_input_widget.dart';
import 'package:local_first/features/verification/presentation/widgets/damage_dispute_bottom_sheet.dart';

/// A bottom sheet for verifying item returns with condition checkboxes gating the verification code input.
///
/// Gated by 3 checkboxes: item returned clean, undamaged/tested, and security deposit release.
/// Provides a link to switch to the damage dispute flow.
class ReturnCodeBottomSheet extends StatefulWidget {
  /// The unique ID of the verification task.
  final String taskId;

  /// The ID of the associated agreement.
  final String agreementId;

  /// Creates a [ReturnCodeBottomSheet].
  const ReturnCodeBottomSheet({
    super.key,
    required this.taskId,
    required this.agreementId,
  });

  /// Displays the return code bottom sheet.
  static Future<bool?> show(
    BuildContext context, {
    required String taskId,
    required String agreementId,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReturnCodeBottomSheet(
        taskId: taskId,
        agreementId: agreementId,
      ),
    );
  }

  @override
  State<ReturnCodeBottomSheet> createState() => _ReturnCodeBottomSheetState();
}

class _ReturnCodeBottomSheetState extends State<ReturnCodeBottomSheet> {
  /// Global key to access the [CodeInputWidgetState] for triggering feedback.
  final GlobalKey<CodeInputWidgetState> _codeInputKey =
      GlobalKey<CodeInputWidgetState>();

  /// Checkbox states.
  bool _cleanChecked = false;
  bool _undamagedChecked = false;
  bool _depositChecked = false;

  /// The currently entered 4-digit code.
  String _enteredCode = '';

  /// Returns true only if all 3 return checklist requirements are satisfied.
  bool get _allChecked => _cleanChecked && _undamagedChecked && _depositChecked;

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
                      content: Text('Item return verification completed successfully.'),
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
                'Confirm Item Return',
                style: DesignTokens.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignTokens.kSpace16),

              // Checklist item 1
              _buildCheckTile(
                value: _cleanChecked,
                label: 'Item returned clean',
                onChanged: (val) {
                  setState(() {
                    _cleanChecked = val ?? false;
                  });
                },
              ),

              // Checklist item 2
              _buildCheckTile(
                value: _undamagedChecked,
                label: 'Item undamaged & tested working',
                onChanged: (val) {
                  setState(() {
                    _undamagedChecked = val ?? false;
                  });
                },
              ),

              // Checklist item 3
              _buildCheckTile(
                value: _depositChecked,
                label: 'Clear to refund security deposit',
                onChanged: (val) {
                  setState(() {
                    _depositChecked = val ?? false;
                  });
                },
              ),

              const SizedBox(height: DesignTokens.kSpace8),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    DamageDisputeBottomSheet.show(
                      context,
                      agreementId: widget.agreementId,
                    );
                  },
                  child: const Text(
                    'Report Damage or Issue',
                    style: TextStyle(
                      color: DesignTokens.colorDanger,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.kSpace16),
              CodeInputWidget(
                key: _codeInputKey,
                enabled: _allChecked,
                onChanged: (code) {
                  setState(() {
                    _enteredCode = code;
                  });
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
                      onPressed: _allChecked &&
                              _enteredCode.length == 4 &&
                              !isLoading
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
                              'SUBMIT RETURN VERIFICATION',
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

  /// Builds a checkbox list tile with a minimum 48dp touch target.
  Widget _buildCheckTile({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: DesignTokens.kTouchMin),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        title: Text(
          label,
          style: DesignTokens.bodyLarge.copyWith(
            color: DesignTokens.colorTextMain,
          ),
        ),
        activeColor: DesignTokens.colorPrimary,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
