import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_first/features/agreements/domain/entities/agreement_entity.dart';
import 'package:local_first/features/agreements/domain/entities/request_entity.dart';
import 'package:local_first/features/agreements/domain/repositories/agreement_repository.dart';
import 'package:local_first/features/agreements/presentation/cubits/transactions_state.dart';

/// Cubit managing state for the transaction history page (AGR-02).
class TransactionsCubit extends Cubit<TransactionsState> {
  /// Repository for fetching user agreements and requests.
  final AgreementRepository _agreementRepository;

  /// Firebase Auth instance for fetching current user UID.
  final FirebaseAuth _auth;

  /// Sets of statuses considered active/in-progress.
  static const Set<AgreementStatus> _activeStatuses = {
    AgreementStatus.draft,
    AgreementStatus.awaitingConsent,
    AgreementStatus.confirmed,
    AgreementStatus.paymentPending,
    AgreementStatus.paymentDeclared,
    AgreementStatus.paymentVerified,
    AgreementStatus.pickupPending,
    AgreementStatus.active,
    AgreementStatus.extensionPending,
    AgreementStatus.extended,
    AgreementStatus.returnPending,
  };

  /// Creates a [TransactionsCubit] with repository and auth dependencies.
  TransactionsCubit({
    required AgreementRepository agreementRepository,
    FirebaseAuth? auth,
  })  : _agreementRepository = agreementRepository,
        _auth = auth ?? FirebaseAuth.instance,
        super(const TransactionsInitial());

  /// Fetches agreements and booking requests for the authenticated user
  /// and categorizes them into requests, active, and completed lists.
  Future<void> loadAgreements() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      emit(const TransactionsError('User is not authenticated.'));
      return;
    }

    emit(const TransactionsLoading());

    // Fetch agreements, inbound requests, and outbound requests concurrently
    final results = await Future.wait([
      _agreementRepository.getAgreementsByUser(userId),
      _agreementRepository.getInboundRequests(userId),
      _agreementRepository.getOutboundRequests(userId),
    ]);

    final agreementsResult = results[0];
    final inboundResult = results[1];
    final outboundResult = results[2];

    // Check if agreements fetch failed
    if (agreementsResult.isLeft()) {
      final failure = agreementsResult.fold((f) => f, (_) => null);
      emit(TransactionsError(failure?.message ?? 'Failed to load agreements.'));
      return;
    }

    final agreements = agreementsResult.getOrElse(() => <AgreementEntity>[]) as List<AgreementEntity>;
    final List<RequestEntity> inboundRequests = inboundResult.isRight()
        ? (inboundResult.getOrElse(() => <RequestEntity>[]) as List<RequestEntity>)
        : <RequestEntity>[];
    final List<RequestEntity> outboundRequests = outboundResult.isRight()
        ? (outboundResult.getOrElse(() => <RequestEntity>[]) as List<RequestEntity>)
        : <RequestEntity>[];

    // Deduplicate requests by ID and sort descending by createdAt
    final Map<String, RequestEntity> requestMap = {};
    for (final req in inboundRequests) {
      requestMap[req.id] = req;
    }
    for (final req in outboundRequests) {
      requestMap[req.id] = req;
    }

    final List<RequestEntity> sortedRequests = requestMap.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final List<AgreementEntity> activeAgreements = [];
    final List<AgreementEntity> completedAgreements = [];

    for (final agreement in agreements) {
      if (_activeStatuses.contains(agreement.status)) {
        activeAgreements.add(agreement);
      } else {
        completedAgreements.add(agreement);
      }
    }

    emit(TransactionsLoaded(
      requests: sortedRequests,
      activeAgreements: activeAgreements,
      completedAgreements: completedAgreements,
    ));
  }
}
