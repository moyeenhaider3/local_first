import 'package:equatable/equatable.dart';
import 'package:local_first/features/agreements/domain/entities/agreement_entity.dart';
import 'package:local_first/features/agreements/domain/entities/timeline_event.dart';
import 'package:local_first/features/verification/domain/entities/verification_task_entity.dart';

/// Base state class for [AgreementTimelineCubit].
abstract class AgreementTimelineState extends Equatable {
  /// Base constructor for [AgreementTimelineState].
  const AgreementTimelineState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading timeline data.
class TimelineInitial extends AgreementTimelineState {
  /// Creates a [TimelineInitial] instance.
  const TimelineInitial();
}

/// State indicating timeline data is being loaded.
class TimelineLoading extends AgreementTimelineState {
  /// Creates a [TimelineLoading] instance.
  const TimelineLoading();
}

/// State emitted when agreement and verification data are updated.
class TimelineUpdated extends AgreementTimelineState {
  /// The current agreement entity.
  final AgreementEntity agreement;

  /// The list of generated timeline events.
  final List<TimelineEvent> events;

  /// The currently active event requiring user action, if any.
  final TimelineEvent? activeEvent;

  /// List of verification tasks associated with the agreement.
  final List<VerificationTaskEntity> tasks;

  /// Creates a [TimelineUpdated] state instance.
  const TimelineUpdated({
    required this.agreement,
    required this.events,
    this.activeEvent,
    required this.tasks,
  });

  @override
  List<Object?> get props => [
        agreement,
        events,
        activeEvent,
        tasks,
      ];
}

/// State emitted when loading timeline data encounters an error.
class TimelineError extends AgreementTimelineState {
  /// The error message describing the failure.
  final String message;

  /// Creates a [TimelineError] state instance.
  const TimelineError(this.message);

  @override
  List<Object?> get props => [message];
}
