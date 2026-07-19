import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_first/core/di/service_locator.dart';
import 'package:local_first/core/theme/design_tokens.dart';
import 'package:local_first/features/verification/presentation/cubits/verification_cubit.dart';
import 'package:local_first/features/verification/presentation/cubits/verification_state.dart';
import 'package:local_first/features/verification/presentation/widgets/code_input_widget.dart';

/// SERVICES feature - Presentation Layer: Completion Code Bottom Sheet
///
/// Modal bottom sheet allowing workers to verify service completion using a 4-digit code.
/// Reuses [CodeInputWidget] and connects to [VerificationCubit] from Phase 4.
class CompletionCodeBottomSheet extends StatefulWidget {
  /// The unique ID of the service completion verification task.
  final String taskId;

  /// Optional job or worker summary description displayed in the bottom sheet.
  final String? jobTitle;

  /// Creates a [CompletionCodeBottomSheet] instance.
  const CompletionCodeBottomSheet({
    super.key,
    required this.taskId,
    this.jobTitle,
  });

  /// Displays the service completion code bottom sheet.
  static Future<bool?> show(
    BuildContext context, {
    required String taskId,
    String? jobTitle,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CompletionCodeBottomSheet(
        taskId: taskId,
        jobTitle: jobTitle,
      ),
    );
  }

  @override
  State<CompletionCodeBottomSheet> createState() =>
      _CompletionCodeBottomSheetState();
}

/// State implementation of [CompletionCodeBottomSheet].
class _CompletionCodeBottomSheetState
    extends State<CompletionCodeBottomSheet> {
  /// Global key to access the [CodeInputWidgetState] for triggering error and success animations.
  final GlobalKey<CodeInputWidgetState> _codeInputKey =
      GlobalKey<CodeInputWidgetState>();

  /// The currently entered 4-digit completion code.
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
          bottom:
              MediaQuery.of(context).viewInsets.bottom + DesignTokens.kSpace24,
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
                      content: Text(
                        'Service completion verified successfully in Local First.',
                      ),
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
              // Drag handle bar
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

              // Title
              Text(
                'Service Completion Code',
                style: DesignTokens.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignTokens.kSpace8),

              if (widget.jobTitle != null && widget.jobTitle!.isNotEmpty) ...[
                Text(
                  widget.jobTitle!,
                  style: DesignTokens.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.colorPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: DesignTokens.kSpace12),
              ],

              // Notice Banner
              Container(
                padding: const EdgeInsets.all(DesignTokens.kSpace16),
                decoration: BoxDecoration(
                  color: DesignTokens.colorSuccess.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: DesignTokens.colorSuccess.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      color: DesignTokens.colorSuccess,
                      size: 24.0,
                    ),
                    const SizedBox(width: DesignTokens.kSpace12),
                    Expanded(
                      child: Text(
                        'Enter the customer\'s 4-digit Service Completion Code to finalize the job, release payout, and enable reviews.',
                        style: DesignTokens.bodySmall.copyWith(
                          color: DesignTokens.colorTextMain,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.kSpace24),

              // 4-Digit Code Input Widget
              CodeInputWidget(
                key: _codeInputKey,
                onChanged: (code) {
                  setState(() {
                    _enteredCode = code;
                  });
                },
                onCompleted: (code) {
                  // Code input auto-updates enteredCode state
                },
              ),
              const SizedBox(height: DesignTokens.kSpace24),

              // Verify Button
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
                          borderRadius: BorderRadius.circular(12.0),
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
                              'VERIFY COMPLETION & CLOSE',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
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
