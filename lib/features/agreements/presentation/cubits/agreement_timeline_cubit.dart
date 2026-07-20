import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_first/features/agreements/domain/entities/agreement_entity.dart';
import 'package:local_first/features/agreements/domain/entities/timeline_event.dart';
import 'package:local_first/features/agreements/domain/repositories/agreement_repository.dart';
import 'package:local_first/features/agreements/presentation/cubits/agreement_timeline_state.dart';
import 'package:local_first/features/verification/domain/entities/verification_task_entity.dart';
import 'package:local_first/features/verification/domain/repositories/verification_repository.dart';

/// Cubit responsible for managing the real-time state and chronological timeline of an active agreement.
class AgreementTimelineCubit extends Cubit<AgreementTimelineState> {
  /// Repository for reading and watching agreement entity updates.
  final AgreementRepository _agreementRepository;

  /// Repository for fetching associated verification tasks.
  final VerificationRepository _verificationRepository;

  /// Stream subscription for real-time agreement updates.
  StreamSubscription<AgreementEntity>? _agreementSubscription;

  /// Creates an [AgreementTimelineCubit] instance with required repository dependencies.
  AgreementTimelineCubit({
    required AgreementRepository agreementRepository,
    required VerificationRepository verificationRepository,
  })  : _agreementRepository = agreementRepository,
        _verificationRepository = verificationRepository,
        super(const TimelineInitial());

  /// Begins real-time listening to agreement changes for the specified [agreementId].
  void listenAgreement(String agreementId) {
    emit(const TimelineLoading());

    _agreementSubscription?.cancel();
    _agreementSubscription = _agreementRepository.watchAgreement(agreementId).listen(
      (agreement) async {
        await _processAgreementUpdate(agreement);
      },
      onError: (error) {
        emit(TimelineError('Failed to watch agreement stream: $error'));
      },
    );
  }

  /// Processes an updated [agreement] by loading verification tasks and building timeline nodes.
  Future<void> _processAgreementUpdate(AgreementEntity agreement) async {
    final tasksResult = await _verificationRepository.getTasksForAgreement(agreement.id);

    final tasks = tasksResult.fold(
      (failure) => <VerificationTaskEntity>[],
      (taskList) => taskList,
    );

    final events = generateTimelineEvents(agreement: agreement, tasks: tasks);

    TimelineEvent? activeEvent;
    for (final event in events) {
      if (event.status == TimelineNodeStatus.active) {
        activeEvent = event;
        break;
      }
    }

    emit(TimelineUpdated(
      agreement: agreement,
      events: events,
      activeEvent: activeEvent,
      tasks: tasks,
    ));
  }

  /// Helper function computing the 5 chronological timeline events for a rental agreement.
  List<TimelineEvent> generateTimelineEvents({
    required AgreementEntity agreement,
    required List<VerificationTaskEntity> tasks,
  }) {
    final List<TimelineEvent> events = [];

    // Helper lookup for verification task by type
    VerificationTaskEntity? getTask(VerificationTaskType type) {
      try {
        return tasks.firstWhere((task) => task.taskType == type);
      } catch (_) {
        return null;
      }
    }

    final paymentTask = getTask(VerificationTaskType.paymentSettlement) ??
        getTask(VerificationTaskType.depositPayment);
    final pickupTask = getTask(VerificationTaskType.pickupInspection);
    final returnTask = getTask(VerificationTaskType.itemReturn) ??
        getTask(VerificationTaskType.depositReturn);

    // 1. Agreement Signed Node
    final isSigned = agreement.status != AgreementStatus.draft &&
        agreement.status != AgreementStatus.awaitingConsent &&
        agreement.status != AgreementStatus.cancelled;
    final isConsentPending = agreement.status == AgreementStatus.awaitingConsent;

    final TimelineNodeStatus signedStatus = isSigned
        ? TimelineNodeStatus.completed
        : (isConsentPending ? TimelineNodeStatus.active : TimelineNodeStatus.pending);

    events.add(TimelineEvent(
      id: 'signed',
      title: 'Agreement Signed & Terms Confirmed',
      subtitle: isSigned
          ? 'Signed by both parties'
          : (isConsentPending
              ? 'Waiting for legal consent'
              : 'Draft agreement'),
      status: signedStatus,
      completedAt: isSigned ? agreement.updatedAt : null,
      actionLabel: isConsentPending ? 'Sign Agreement' : null,
      actionRoute: isConsentPending ? '/home/legal-consent/${agreement.id}' : null,
    ));

    // 2. Payment Verification Node
    final isPaymentVerified = (paymentTask != null && paymentTask.status == VerificationStatus.verified) ||
        agreement.status == AgreementStatus.paymentVerified ||
        agreement.status == AgreementStatus.pickupPending ||
        agreement.status == AgreementStatus.active ||
        agreement.status == AgreementStatus.returnPending ||
        agreement.status == AgreementStatus.completed;

    final isPaymentActive = !isPaymentVerified &&
        isSigned &&
        (agreement.status == AgreementStatus.paymentPending ||
            agreement.status == AgreementStatus.paymentDeclared ||
            (paymentTask != null &&
                (paymentTask.status == VerificationStatus.pending ||
                    paymentTask.status == VerificationStatus.initiatorConfirmed)));

    final TimelineNodeStatus paymentStatus = isPaymentVerified
        ? TimelineNodeStatus.completed
        : (isPaymentActive ? TimelineNodeStatus.active : TimelineNodeStatus.pending);

    events.add(TimelineEvent(
      id: 'payment',
      title: 'Payment Verification',
      subtitle: isPaymentVerified
          ? 'Payment verified successfully'
          : (isPaymentActive
              ? 'Confirm UPI payment settlement'
              : 'Awaiting contract signature'),
      status: paymentStatus,
      completedAt: isPaymentVerified ? (paymentTask?.completedAt ?? agreement.updatedAt) : null,
      actionLabel: isPaymentActive
          ? (agreement.status == AgreementStatus.paymentPending ? 'Deposit Escrow' : 'Verify Payment')
          : null,
      actionRoute: isPaymentActive
          ? (agreement.status == AgreementStatus.paymentPending ? '/home/vfy/escrow/${agreement.id}' : '/home/vfy/payment/${paymentTask?.id ?? agreement.id}')
          : null,
    ));

    // 3. Item Handover & Pickup Verification Node
    final isPickupVerified = (pickupTask != null && pickupTask.status == VerificationStatus.verified) ||
        agreement.status == AgreementStatus.active ||
        agreement.status == AgreementStatus.extensionPending ||
        agreement.status == AgreementStatus.extended ||
        agreement.status == AgreementStatus.returnPending ||
        agreement.status == AgreementStatus.completed;

    final isPickupActive = !isPickupVerified &&
        isPaymentVerified &&
        (agreement.status == AgreementStatus.pickupPending ||
            (pickupTask != null &&
                (pickupTask.status == VerificationStatus.pending ||
                    pickupTask.status == VerificationStatus.initiatorConfirmed)));

    final TimelineNodeStatus pickupStatus = isPickupVerified
        ? TimelineNodeStatus.completed
        : (isPickupActive ? TimelineNodeStatus.active : TimelineNodeStatus.pending);

    events.add(TimelineEvent(
      id: 'pickup',
      title: 'Item Handover & Pickup Verification',
      subtitle: isPickupVerified
          ? 'Item pickup verified'
          : (isPickupActive
              ? 'Inspect item condition & enter pickup code'
              : 'Awaiting payment verification'),
      status: pickupStatus,
      completedAt: isPickupVerified ? (pickupTask?.completedAt ?? agreement.updatedAt) : null,
      actionLabel: isPickupActive ? 'Enter Pickup Code' : null,
      actionRoute: isPickupActive ? '/home/vfy/pickup/${pickupTask?.id ?? agreement.id}' : null,
    ));

    // 4. Rental Active Period Node
    final isRentalActive = agreement.status == AgreementStatus.active ||
        agreement.status == AgreementStatus.extensionPending ||
        agreement.status == AgreementStatus.extended;

    final isRentalCompleted = agreement.status == AgreementStatus.returnPending ||
        agreement.status == AgreementStatus.completed ||
        agreement.status == AgreementStatus.damageDisputed;

    final TimelineNodeStatus activePeriodStatus = isRentalCompleted
        ? TimelineNodeStatus.completed
        : (isRentalActive ? TimelineNodeStatus.active : TimelineNodeStatus.pending);

    events.add(TimelineEvent(
      id: 'active_period',
      title: 'Rental Active Period',
      subtitle: isRentalCompleted
          ? 'Rental active period finished'
          : (isRentalActive
              ? 'Item currently with renter (${agreement.durationDays} days)'
              : 'Awaiting handover completion'),
      status: activePeriodStatus,
    ));

    // 5. Return Verification & Deposit Refund Node
    final isReturnVerified = (returnTask != null && returnTask.status == VerificationStatus.verified) ||
        agreement.status == AgreementStatus.completed;

    final isDisputed = agreement.status == AgreementStatus.damageDisputed;

    final isReturnActive = !isReturnVerified &&
        (isRentalActive || isRentalCompleted) &&
        (agreement.status == AgreementStatus.returnPending ||
            isDisputed ||
            (returnTask != null &&
                (returnTask.status == VerificationStatus.pending ||
                    returnTask.status == VerificationStatus.initiatorConfirmed)));

    final TimelineNodeStatus returnStatus = isReturnVerified
        ? TimelineNodeStatus.completed
        : (isReturnActive ? TimelineNodeStatus.active : TimelineNodeStatus.pending);

    events.add(TimelineEvent(
      id: 'return',
      title: 'Return Verification & Deposit Refund',
      subtitle: isReturnVerified
          ? 'Item returned & deposit refunded'
          : (isDisputed
              ? 'Damage dispute reported & under review'
              : (isReturnActive
                  ? 'Confirm item return & refund deposit'
                  : 'Awaiting rental completion')),
      status: returnStatus,
      completedAt: isReturnVerified ? (returnTask?.completedAt ?? agreement.updatedAt) : null,
      actionLabel: isDisputed
          ? 'View Dispute Details'
          : (isReturnActive ? 'Verify Item Return' : null),
      actionRoute: isDisputed
          ? '/home/vfy/dispute/${agreement.id}'
          : (isReturnActive ? '/home/vfy/return/${returnTask?.id ?? agreement.id}' : null),
    ));

    return events;
  }

  @override
  Future<void> close() {
    _agreementSubscription?.cancel();
    return super.close();
  }
}
