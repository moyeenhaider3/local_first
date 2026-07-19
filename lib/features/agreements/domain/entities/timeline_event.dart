import 'package:equatable/equatable.dart';

/// Represents the status of an individual step node in the agreement timeline.
enum TimelineNodeStatus {
  /// The milestone step has been completed.
  completed,

  /// The milestone step is currently active and awaiting action.
  active,

  /// The milestone step has not been reached yet.
  pending,
}

/// Domain value object representing a single chronological event in the agreement timeline.
class TimelineEvent extends Equatable {
  /// Unique identifier for this timeline event node.
  final String id;

  /// Human-readable title of the timeline step.
  final String title;

  /// Contextual subtitle or descriptive status note for the node.
  final String? subtitle;

  /// Current status of the node: completed, active, or pending.
  final TimelineNodeStatus status;

  /// Timestamp when the milestone was completed, if applicable.
  final DateTime? completedAt;

  /// Route path or action target for navigation when action button is tapped.
  final String? actionRoute;

  /// Label text for the action button rendered on active nodes.
  final String? actionLabel;

  /// Creates a new [TimelineEvent] instance.
  const TimelineEvent({
    required this.id,
    required this.title,
    this.subtitle,
    required this.status,
    this.completedAt,
    this.actionRoute,
    this.actionLabel,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        subtitle,
        status,
        completedAt,
        actionRoute,
        actionLabel,
      ];
}
