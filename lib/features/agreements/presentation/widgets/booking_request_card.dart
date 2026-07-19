import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:local_first/core/router/route_names.dart';
import 'package:local_first/core/theme/design_tokens.dart';
import 'package:local_first/features/agreements/domain/entities/request_entity.dart';

/// Card widget displaying a booking or service request item in the activity list.
///
/// Features status badges, requested duration/dates, total cost, and displays
/// owner feedback / rejection reason when applicable.
class BookingRequestCard extends StatelessWidget {
  /// The request entity data to display.
  final RequestEntity request;

  /// Creates a [BookingRequestCard] instance.
  const BookingRequestCard({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final bool isReceiver = currentUserId == request.receiverId;

    final String startDateStr = dateFormat.format(request.proposedStartDate);
    final String endDateStr = request.proposedEndDate != null
        ? dateFormat.format(request.proposedEndDate!)
        : 'N/A';

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: DesignTokens.kEdgeMargin,
        vertical: DesignTokens.kSpace8,
      ),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: DesignTokens.colorSurface,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (isReceiver &&
              (request.status == RequestStatus.sent ||
                  request.status == RequestStatus.viewed)) {
            context.pushNamed(
              RouteNames.ownerRequestReview,
              pathParameters: {'requestId': request.id},
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.kSpace16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Title and Status Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.listingTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isReceiver ? 'Received Request' : 'Sent Request',
                          style: DesignTokens.bodySmall.copyWith(
                            color: DesignTokens.colorTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(request.status),
                ],
              ),
              const SizedBox(height: DesignTokens.kSpace12),

              // Details Row: Dates & Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: DesignTokens.colorTextMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$startDateStr - $endDateStr',
                        style: DesignTokens.bodySmall.copyWith(
                          color: DesignTokens.colorTextMain,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '₹${request.estimatedTotal.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: DesignTokens.colorPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Rejection Reason Banner if applicable
              if (request.status == RequestStatus.rejected &&
                  request.rejectionReason != null &&
                  request.rejectionReason!.trim().isNotEmpty) ...[
                const SizedBox(height: DesignTokens.kSpace12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: DesignTokens.colorDanger,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Reason: ${request.rejectionReason}',
                          style: DesignTokens.bodySmall.copyWith(
                            color: const Color(0xFF991B1B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a styled status badge widget based on [RequestStatus].
  Widget _buildStatusBadge(RequestStatus status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case RequestStatus.sent:
        backgroundColor = const Color(0xFFEFF6FF);
        textColor = const Color(0xFF1D4ED8);
        label = 'SENT';
        break;
      case RequestStatus.viewed:
        backgroundColor = const Color(0xFFF3E8FF);
        textColor = const Color(0xFF7E22CE);
        label = 'VIEWED';
        break;
      case RequestStatus.accepted:
        backgroundColor = const Color(0xFFECFDF5);
        textColor = const Color(0xFF047857);
        label = 'ACCEPTED';
        break;
      case RequestStatus.rejected:
        backgroundColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFB91C1C);
        label = 'DECLINED';
        break;
      case RequestStatus.expired:
        backgroundColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
        label = 'EXPIRED';
        break;
      case RequestStatus.cancelledByRequester:
        backgroundColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
        label = 'CANCELLED';
        break;
      default:
        backgroundColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
        label = status.name.toUpperCase();
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
