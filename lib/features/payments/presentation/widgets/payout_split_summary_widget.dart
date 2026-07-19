import 'package:flutter/material.dart';
import 'package:local_first/core/theme/design_tokens.dart';
import 'package:local_first/features/payments/domain/entities/payment_entity.dart';

/// Summary card widget displaying real-time escrow deposits, split breakdowns, payment proof, and payout status in Local First.
class PayoutSplitSummaryWidget extends StatelessWidget {
  /// The payment entity record to display.
  final PaymentEntity payment;

  /// Creates a [PayoutSplitSummaryWidget] instance.
  const PayoutSplitSummaryWidget({
    super.key,
    required this.payment,
  });

  /// Opens full-screen modal image viewer for the payment proof screenshot.
  void _openProofViewer(BuildContext context, String proofUrl) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(DesignTokens.kEdgeMargin),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  proofUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.black,
                    padding: const EdgeInsets.all(32.0),
                    child: const Text(
                      'Failed to load payment proof image',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28.0),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isReleased = payment.status == PaymentStatus.payoutReleased;
    final badgeColor = isReleased ? DesignTokens.colorSuccess : DesignTokens.colorWarning;
    final badgeText = isReleased ? 'Payout Released' : 'Escrow Held';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: DesignTokens.kSpace8),
      padding: const EdgeInsets.all(DesignTokens.kSpace16),
      decoration: BoxDecoration(
        color: DesignTokens.colorSurface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with title and status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: DesignTokens.colorPrimary,
                    size: 20.0,
                  ),
                  const SizedBox(width: DesignTokens.kSpace8),
                  Text(
                    'ESCROW & PAYOUT SUMMARY',
                    style: DesignTokens.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: DesignTokens.colorTextMuted,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: badgeColor),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.kSpace16),

          // Itemized financial breakdown
          _buildDetailRow('Total Escrow Locked', '₹${payment.totalAmount.toStringAsFixed(2)}'),
          const SizedBox(height: DesignTokens.kSpace8),
          _buildDetailRow('Platform Fee Deducted (5%)', '₹${payment.platformFee.toStringAsFixed(2)}'),
          const SizedBox(height: DesignTokens.kSpace8),
          _buildDetailRow(
            'Net Payout to Owner (95%)',
            '₹${payment.ownerPayout.toStringAsFixed(2)}',
            isHighlight: true,
          ),
          const SizedBox(height: DesignTokens.kSpace8),
          _buildDetailRow('Amount Paid', '₹${payment.amountPaid.toStringAsFixed(2)}'),

          if (payment.remarks != null && payment.remarks!.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.kSpace8),
            _buildDetailRow('Remarks / Ref ID', payment.remarks!),
          ],

          // Payment proof thumbnail if available
          if (payment.proofUrl != null && payment.proofUrl!.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.kSpace16),
            Text(
              'PAYMENT PROOF SCREENSHOT',
              style: DesignTokens.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: DesignTokens.colorTextMuted,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: DesignTokens.kSpace8),
            GestureDetector(
              onTap: () => _openProofViewer(context, payment.proofUrl!),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      payment.proofUrl!,
                      height: 110.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 80.0,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.zoom_in, color: Colors.white, size: 14.0),
                          SizedBox(width: 4.0),
                          Text(
                            'Tap to view',
                            style: TextStyle(color: Colors.white, fontSize: 10.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds a key-value detail row formatted for the summary card.
  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isHighlight
              ? DesignTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)
              : DesignTokens.bodyMedium.copyWith(color: DesignTokens.colorTextMuted),
        ),
        Text(
          value,
          style: isHighlight
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
