import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:local_first/features/services/domain/entities/service_request_entity.dart';

/// SERVICES feature - Presentation Layer: Job Card Widget
/// Displays an inbound or active service request with customer details, scheduled date, estimated rate, and status action buttons.
class JobCard extends StatelessWidget {
  /// The service request entity data to display.
  final ServiceRequestEntity request;

  /// Callback fired when worker accepts the service job request.
  final VoidCallback? onAccept;

  /// Callback fired when worker taps to open chat/contact with customer.
  final VoidCallback? onChat;

  /// Callback fired when worker marks job as completed.
  final VoidCallback? onComplete;

  /// Creates a [JobCard] widget.
  const JobCard({
    super.key,
    required this.request,
    this.onAccept,
    this.onChat,
    this.onComplete,
  });

  /// Helper method returning status color badge based on service request status.
  Color _getStatusColor(ServiceRequestStatus status) {
    switch (status) {
      case ServiceRequestStatus.pending:
        return Colors.orange;
      case ServiceRequestStatus.accepted:
        return Colors.blue;
      case ServiceRequestStatus.inProgress:
        return Colors.purple;
      case ServiceRequestStatus.completed:
        return Colors.green;
      case ServiceRequestStatus.rejected:
      case ServiceRequestStatus.cancelled:
        return Colors.red;
    }
  }

  /// Helper method formatting status code into human readable label.
  String _getStatusLabel(ServiceRequestStatus status) {
    switch (status) {
      case ServiceRequestStatus.pending:
        return 'Pending';
      case ServiceRequestStatus.accepted:
        return 'Accepted';
      case ServiceRequestStatus.inProgress:
        return 'In Progress';
      case ServiceRequestStatus.completed:
        return 'Completed';
      case ServiceRequestStatus.rejected:
        return 'Rejected';
      case ServiceRequestStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(request.status);
    final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(request.scheduledDate);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Customer Name & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    request.customerName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    _getStatusLabel(request.status),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Job Description
            Text(
              request.jobDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyLarge?.color,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Scheduled Date & Estimated Rate row
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    formattedDate,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                Text(
                  '₹${request.estimatedRate.toStringAsFixed(0)} / ${request.rateUnit}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action Buttons based on status
            Row(
              children: [
                if (request.status == ServiceRequestStatus.pending) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Accept Job'),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (request.status == ServiceRequestStatus.accepted ||
                    request.status == ServiceRequestStatus.inProgress) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onChat,
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: const Text('Contact'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onComplete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Complete'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
