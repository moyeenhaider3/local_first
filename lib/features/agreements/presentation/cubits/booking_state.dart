import 'package:equatable/equatable.dart';
import 'package:local_first/features/agreements/domain/entities/agreement_entity.dart';
import 'package:local_first/features/agreements/domain/entities/request_entity.dart';

sealed class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {
  const BookingInitial();
}

class BookingLoading extends BookingState {
  const BookingLoading();
}

class RatesCalculated extends BookingState {
  final double totalAmount;
  final double depositAmount;
  final double dailyRate;
  final int durationDays;

  const RatesCalculated({
    required this.totalAmount,
    required this.depositAmount,
    required this.dailyRate,
    required this.durationDays,
  });

  @override
  List<Object?> get props => [totalAmount, depositAmount, dailyRate, durationDays];
}

class RequestSending extends BookingState {
  const RequestSending();
}

class RequestSent extends BookingState {
  final String requestId;

  const RequestSent({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}

class InboundRequestsLoaded extends BookingState {
  final List<RequestEntity> requests;

  const InboundRequestsLoaded({required this.requests});

  @override
  List<Object?> get props => [requests];
}

class RequestAccepted extends BookingState {
  final AgreementEntity agreement;

  const RequestAccepted({required this.agreement});

  @override
  List<Object?> get props => [agreement];
}

class RequestRejected extends BookingState {
  const RequestRejected();
}

class SigningInProgress extends BookingState {
  const SigningInProgress();
}

class ContractSignedSuccess extends BookingState {
  final AgreementEntity agreement;

  const ContractSignedSuccess({required this.agreement});

  @override
  List<Object?> get props => [agreement];
}

class BookingError extends BookingState {
  final String message;

  const BookingError({required this.message});

  @override
  List<Object?> get props => [message];
}
