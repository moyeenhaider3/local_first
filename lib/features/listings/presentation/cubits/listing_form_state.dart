import 'package:equatable/equatable.dart';

/// Presentation Layer: Sealed Listing Form State hierarchy.
sealed class ListingFormState extends Equatable {
  const ListingFormState();

  @override
  List<Object?> get props => [];
}

class ListingFormInitial extends ListingFormState {
  const ListingFormInitial();
}

class ListingFormValidating extends ListingFormState {
  const ListingFormValidating();
}

class ListingFormUploading extends ListingFormState {
  final double progress;

  const ListingFormUploading({required this.progress});

  @override
  List<Object?> get props => [progress];
}

class ListingFormSubmitting extends ListingFormState {
  const ListingFormSubmitting();
}

class ListingFormSuccess extends ListingFormState {
  final String listingId;

  const ListingFormSuccess({required this.listingId});

  @override
  List<Object?> get props => [listingId];
}

class ListingFormError extends ListingFormState {
  final String message;

  const ListingFormError({required this.message});

  @override
  List<Object?> get props => [message];
}
