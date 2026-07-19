import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:local_first/core/theme/design_tokens.dart';
import 'package:local_first/features/agreements/domain/entities/agreement_entity.dart';
import 'package:local_first/features/agreements/presentation/widgets/status_badge_widget.dart';

/// A card widget displaying a summary of an agreement transaction in the history list.
class TransactionCard extends StatelessWidget {
  /// The agreement entity data to display.
  final AgreementEntity agreement;

  /// Optional callback override when card is tapped. Defaults to navigating to the agreement console.
  final VoidCallback? onTap;

  /// Creates a [TransactionCard] instance for the given [agreement].
  const TransactionCard({
    super.key,
    required this.agreement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final dateRangeStr =
        '${dateFormat.format(agreement.startDate)} – ${dateFormat.format(agreement.endDate)}';

    return InkWell(
      onTap: onTap ?? () => context.push('/home/agreement/${agreement.id}'),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.kEdgeMargin,
              vertical: DesignTokens.kSpace12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left: Listing Image Thumbnail (64x64dp)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: SizedBox(
                    width: 64.0,
                    height: 64.0,
                    child: _buildThumbnail(),
                  ),
                ),
                const SizedBox(width: DesignTokens.kSpace12),
                // Center Column: Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agreement.listingTitle,
                        style: DesignTokens.titleMedium.copyWith(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: DesignTokens.kSpace4),
                      Text(
                        dateRangeStr,
                        style: DesignTokens.caption.copyWith(
                          color: DesignTokens.colorTextMuted,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.kSpace4),
                      Text(
                        '₹${agreement.totalAmount.toStringAsFixed(2)}',
                        style: DesignTokens.labelBold.copyWith(
                          color: DesignTokens.colorPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: DesignTokens.kSpace8),
                // Right Column: Status Badge
                StatusBadgeWidget(status: agreement.status),
              ],
            ),
          ),
          const Divider(
            height: 1.0,
            thickness: 1.0,
            color: Color(0xFFE2E8F0),
          ),
        ],
      ),
    );
  }

  /// Builds thumbnail image or fallback icon widget.
  Widget _buildThumbnail() {
    final url = agreement.listingThumbnailUrl;
    if (url != null && url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: const Color(0xFFF1F5F9),
          child: const Center(
            child: SizedBox(
              width: 16.0,
              height: 16.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: DesignTokens.colorPrimary,
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholderIcon(),
      );
    }
    return _buildPlaceholderIcon();
  }

  /// Placeholder icon when image is unavailable.
  Widget _buildPlaceholderIcon() {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: const Icon(
        Icons.inventory_2_outlined,
        color: DesignTokens.colorTextMuted,
        size: 28.0,
      ),
    );
  }
}
