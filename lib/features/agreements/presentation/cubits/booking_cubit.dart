import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_first/features/agreements/domain/entities/request_entity.dart';
import 'package:local_first/features/agreements/domain/entities/signature_metadata_entity.dart';
import 'package:local_first/features/agreements/domain/repositories/agreement_repository.dart';
import 'package:local_first/features/agreements/presentation/cubits/booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final AgreementRepository repository;

  BookingCubit({required this.repository}) : super(const BookingInitial());

  /// Calculates duration and total amounts, then emits [RatesCalculated].
  void calculateRates({
    required double pricePerDay,
    required double securityDeposit,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final difference = endDate.difference(startDate).inDays;
    final durationDays = difference <= 0 ? 1 : difference;
    final totalAmount = pricePerDay * durationDays;

    emit(RatesCalculated(
      totalAmount: totalAmount,
      depositAmount: securityDeposit,
      dailyRate: pricePerDay,
      durationDays: durationDays,
    ));
  }

  /// Sends a rental/service request.
  Future<void> sendBookingRequest(RequestEntity request) async {
    emit(const RequestSending());
    final result = await repository.createRequest(request);
    result.fold(
      (failure) => emit(BookingError(message: failure.message)),
      (requestId) => emit(RequestSent(requestId: requestId)),
    );
  }

  /// Loads inbound requests for a listing owner/worker.
  Future<void> loadInboundRequests(String receiverId) async {
    emit(const BookingLoading());
    final result = await repository.getInboundRequests(receiverId);
    result.fold(
      (failure) => emit(BookingError(message: failure.message)),
      (requests) => emit(InboundRequestsLoaded(requests: requests)),
    );
  }

  /// Accepts an incoming request, transitioning it to a draft agreement.
  Future<void> acceptBookingRequest(String requestId) async {
    emit(const BookingLoading());
    final result = await repository.acceptRequest(requestId);
    result.fold(
      (failure) => emit(BookingError(message: failure.message)),
      (agreement) => emit(RequestAccepted(agreement: agreement)),
    );
  }

  /// Rejects an incoming request.
  Future<void> rejectBookingRequest(String requestId, String? reason) async {
    emit(const BookingLoading());
    final result = await repository.rejectRequest(requestId, reason);
    result.fold(
      (failure) => emit(BookingError(message: failure.message)),
      (_) => emit(const RequestRejected()),
    );
  }

  /// Submits the digital signature metadata and records consent.
  Future<void> signBookingAgreement(String agreementId, SignatureMetadataEntity signature) async {
    emit(const SigningInProgress());
    final result = await repository.signAgreement(agreementId, signature);
    
    await result.fold(
      (failure) async => emit(BookingError(message: failure.message)),
      (_) async {
        final agreementResult = await repository.getAgreement(agreementId);
        agreementResult.fold(
          (failure) => emit(BookingError(message: failure.message)),
          (agreement) => emit(ContractSignedSuccess(agreement: agreement)),
        );
      },
    );
  }
}
