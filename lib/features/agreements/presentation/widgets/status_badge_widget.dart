import 'package:flutter/material.dart';
import 'package:local_first/core/theme/design_tokens.dart';
import 'package:local_first/features/agreements/domain/entities/agreement_entity.dart';

/// A widget that displays a colored pill badge for an [AgreementStatus].
class StatusBadgeWidget extends StatelessWidget {
  /// The current agreement status to render.
  final AgreementStatus status;

  /// Creates a [StatusBadgeWidget] with the specified [status].
  const StatusBadgeWidget({
    super.key,
    required this.status,
  });

  /// Returns the background color associated with the given [status].
  Color _getBackgroundColor(AgreementStatus status) {
    switch (status) {
      case AgreementStatus.draft:
      case AgreementStatus.cancelled:
      case AgreementStatus.archived:
        return const Color(0xFF94A3B8); // Slate / Gray

      case AgreementStatus.awaitingConsent:
      case AgreementStatus.paymentPending:
      case AgreementStatus.pickupPending:
      case AgreementStatus.extensionPending:
      case AgreementStatus.returnPending:
        return const Color(0xFFD97706); // Amber / Warning

      case AgreementStatus.confirmed:
      case AgreementStatus.paymentDeclared:
        return const Color(0xFF3B82F6); // Blue / Info

      case AgreementStatus.paymentVerified:
      case AgreementStatus.active:
      case AgreementStatus.extended:
        return const Color(0xFF16A34A); // Green / Success

      case AgreementStatus.completed:
        return const Color(0xFF0D9488); // Teal

      case AgreementStatus.damageDisputed:
        return const Color(0xFFDC2626); // Crimson / Danger
    }
  }

  /// Returns human-readable label text for the given [status].
  String _getStatusText(AgreementStatus status) {
    switch (status) {
      case AgreementStatus.draft:
        return 'DRAFT';
      case AgreementStatus.awaitingConsent:
        return 'AWAITING CONSENT';
      case AgreementStatus.confirmed:
        return 'CONFIRMED';
      case AgreementStatus.paymentPending:
        return 'PAYMENT PENDING';
      case AgreementStatus.paymentDeclared:
        return 'PAYMENT DECLARED';
      case AgreementStatus.paymentVerified:
        return 'PAYMENT VERIFIED';
      case AgreementStatus.pickupPending:
        return 'PICKUP PENDING';
      case AgreementStatus.active:
        return 'ACTIVE';
      case AgreementStatus.extensionPending:
        return 'EXTENSION PENDING';
      case AgreementStatus.extended:
        return 'EXTENDED';
      case AgreementStatus.returnPending:
        return 'RETURN PENDING';
      case AgreementStatus.completed:
        return 'COMPLETED';
      case AgreementStatus.damageDisputed:
        return 'DISPUTED';
      case AgreementStatus.cancelled:
        return 'CANCELLED';
      case AgreementStatus.archived:
        return 'ARCHIVED';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor(status);
    final text = _getStatusText(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.kSpace12,
        vertical: DesignTokens.kSpace4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Text(
        text,
        style: DesignTokens.labelBold.copyWith(
          color: Colors.white,
          fontSize: 11.0,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
