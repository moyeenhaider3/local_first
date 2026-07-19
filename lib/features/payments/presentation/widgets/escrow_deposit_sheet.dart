import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_first/core/di/service_locator.dart';
import 'package:local_first/core/theme/design_tokens.dart';
import 'package:local_first/features/payments/presentation/cubits/payment_cubit.dart';
import 'package:local_first/features/payments/presentation/cubits/payment_state.dart';

/// Modal bottom sheet allowing renters to review itemized escrow breakdown and deposit funds in Local First.
class EscrowDepositSheet extends StatefulWidget {
  /// Unique identifier of the associated rental agreement.
  final String agreementId;

  /// The rental fee for the rental period.
  final double rentalFee;

  /// The refundable security deposit amount.
  final double depositAmount;

  /// Creates an [EscrowDepositSheet] instance.
  const EscrowDepositSheet({
    super.key,
    required this.agreementId,
    required this.rentalFee,
    required this.depositAmount,
  });

  /// Displays the [EscrowDepositSheet] modal.
  static Future<bool?> show(
    BuildContext context, {
    required String agreementId,
    required double rentalFee,
    required double depositAmount,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EscrowDepositSheet(
        agreementId: agreementId,
        rentalFee: rentalFee,
        depositAmount: depositAmount,
      ),
    );
  }

  @override
  State<EscrowDepositSheet> createState() => _EscrowDepositSheetState();
}

class _EscrowDepositSheetState extends State<EscrowDepositSheet> {
  /// Available mock payment methods.
  final List<String> _paymentMethods = const ['UPI', 'Card', 'NetBanking'];

  /// Currently selected payment method.
  String _selectedMethod = 'UPI';

  /// Calculates the 5% platform fee based on the rental fee.
  double get _platformFee => widget.rentalFee * 0.05;

  /// Calculates the total payable amount including rental fee, platform fee, and deposit.
  double get _totalPayable => widget.rentalFee + _platformFee + widget.depositAmount;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PaymentCubit>(
      create: (context) => sl<PaymentCubit>(),
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
        child: BlocListener<PaymentCubit, PaymentState>(
          listener: (context, state) {
            if (state is PaymentEscrowHeld) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment locked in escrow successfully.'),
                  backgroundColor: DesignTokens.colorSuccess,
                ),
              );
              Navigator.of(context).pop(true);
            } else if (state is PaymentError) {
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
              // Bottom sheet drag handle indicator
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
                'Lock Escrow Deposit',
                style: DesignTokens.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignTokens.kSpace4),
              Text(
                'Local First Secure Escrow Protection',
                style: DesignTokens.bodySmall.copyWith(
                  color: DesignTokens.colorTextMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignTokens.kSpace24),

              // Breakdown Container
              Container(
                padding: const EdgeInsets.all(DesignTokens.kSpace16),
                decoration: BoxDecoration(
                  color: DesignTokens.colorBackground,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildRow('Rental Fee', '₹${widget.rentalFee.toStringAsFixed(2)}'),
                    const SizedBox(height: DesignTokens.kSpace8),
                    _buildRow('Platform Fee (5%)', '₹${_platformFee.toStringAsFixed(2)}'),
                    const SizedBox(height: DesignTokens.kSpace8),
                    _buildRow('Refundable Deposit', '₹${widget.depositAmount.toStringAsFixed(2)}'),
                    const Divider(height: DesignTokens.kSpace24),
                    _buildRow(
                      'Total Payable',
                      '₹${_totalPayable.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: DesignTokens.kSpace24),

              // Payment Method Selector Title
              Text(
                'PAYMENT METHOD',
                style: DesignTokens.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.colorTextMuted,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: DesignTokens.kSpace12),

              // Payment Method Choice Chips
              Row(
                children: _paymentMethods.map((method) {
                  final isSelected = _selectedMethod == method;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Center(
                          child: Text(
                            method,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : DesignTokens.colorTextMain,
                            ),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: DesignTokens.colorPrimary,
                        backgroundColor: Colors.grey[100],
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedMethod = method;
                            });
                          }
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: DesignTokens.kSpace32),

              // Action button to confirm and lock escrow
              Builder(
                builder: (context) {
                  final state = context.watch<PaymentCubit>().state;
                  final isLoading = state is PaymentLoading;

                  return SizedBox(
                    height: 52.0,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              context.read<PaymentCubit>().holdPaymentInEscrow(
                                    agreementId: widget.agreementId,
                                    totalAmount: _totalPayable,
                                    amountPaid: _totalPayable,
                                    paymentMethod: _selectedMethod,
                                    remarks: 'Escrow lock via Local First $_selectedMethod',
                                  );
                            },
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
                          : Text(
                              'CONFIRM & LOCK ESCROW (₹${_totalPayable.toStringAsFixed(2)})',
                              style: const TextStyle(
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

  /// Builds a financial breakdown row with title and formatted value string.
  Widget _buildRow(String title, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: isTotal
              ? DesignTokens.titleMedium.copyWith(fontWeight: FontWeight.bold)
              : DesignTokens.bodyMedium.copyWith(color: DesignTokens.colorTextMuted),
        ),
        Text(
          value,
          style: isTotal
              ? DesignTokens.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.colorPrimary,
                )
              : DesignTokens.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.colorTextMain,
                ),
        ),
      ],
    );
  }
}
