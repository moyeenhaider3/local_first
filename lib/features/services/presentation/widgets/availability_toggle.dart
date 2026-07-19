import 'package:flutter/material.dart';
import 'package:local_first/features/services/domain/entities/worker_availability.dart';

/// SERVICES feature - Presentation Layer: Availability Toggle Widget
/// Interactive control allowing service workers to toggle their current work availability state.
class AvailabilityToggle extends StatelessWidget {
  /// Currently active availability status.
  final WorkerAvailability currentStatus;

  /// Callback fired when worker selects a new availability status.
  final ValueChanged<WorkerAvailability> onChanged;

  /// Flag indicating if status update operation is currently loading.
  final bool isLoading;

  /// Creates an [AvailabilityToggle] widget.
  const AvailabilityToggle({
    super.key,
    required this.currentStatus,
    required this.onChanged,
    this.isLoading = false,
  });

  /// Helper method returning the indicator color for each availability status.
  Color _getBadgeColor(WorkerAvailability status, ThemeData theme) {
    switch (status) {
      case WorkerAvailability.availableNow:
      case WorkerAvailability.availableToday:
      case WorkerAvailability.availableThisWeek:
        return Colors.green;
      case WorkerAvailability.busy:
      case WorkerAvailability.byAppointment:
        return Colors.orange;
      case WorkerAvailability.onLeave:
      case WorkerAvailability.inactive:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: SegmentedButton<WorkerAvailability>(
        showSelectedIcon: false,
        segments: <ButtonSegment<WorkerAvailability>>[
          ButtonSegment<WorkerAvailability>(
            value: WorkerAvailability.availableNow,
            label: Text(
              'Available',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getBadgeColor(WorkerAvailability.availableNow, theme),
              ),
            ),
            icon: Icon(
              Icons.circle,
              size: 10,
              color: _getBadgeColor(WorkerAvailability.availableNow, theme),
            ),
          ),
          ButtonSegment<WorkerAvailability>(
            value: WorkerAvailability.busy,
            label: Text(
              'Busy',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getBadgeColor(WorkerAvailability.busy, theme),
              ),
            ),
            icon: Icon(
              Icons.circle,
              size: 10,
              color: _getBadgeColor(WorkerAvailability.busy, theme),
            ),
          ),
          ButtonSegment<WorkerAvailability>(
            value: WorkerAvailability.inactive,
            label: Text(
              'Offline',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getBadgeColor(WorkerAvailability.inactive, theme),
              ),
            ),
            icon: Icon(
              Icons.circle,
              size: 10,
              color: _getBadgeColor(WorkerAvailability.inactive, theme),
            ),
          ),
        ],
        selected: <WorkerAvailability>{currentStatus},
        onSelectionChanged: isLoading
            ? null
            : (Set<WorkerAvailability> newSelection) {
                if (newSelection.isNotEmpty) {
                  onChanged(newSelection.first);
                }
              },
      ),
    );
  }
}
