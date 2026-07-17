import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_first/features/listings/domain/entities/listing_entity.dart';
import 'package:local_first/features/listings/domain/repositories/discovery_repository.dart';
import 'package:local_first/features/listings/presentation/cubits/listing_form_state.dart';

class ListingFormCubit extends Cubit<ListingFormState> {
  final DiscoveryRepository repository;

  ListingFormCubit({required this.repository}) : super(const ListingFormInitial());

  Future<void> submitListing({
    required String ownerId,
    required String ownerDisplayName,
    required String? ownerPhotoUrl,
    required ListingType listingType,
    required String categoryId,
    required String categoryName,
    required String title,
    required String description,
    required List<dynamic> imageFiles,
    required double? pricePerDay,
    required double? securityDeposit,
    required double? startingRate,
    required String? rateUnit,
    required double pickupRadiusKm,
    required GeoPoint location,
    required String geohash,
    required List<String> tags,
  }) async {
    emit(const ListingFormValidating());

    // Basic validation constraints matching requirements
    if (title.trim().length < 3) {
      emit(const ListingFormError(message: 'Title must be at least 3 characters.'));
      return;
    }
    if (description.trim().length < 15) {
      emit(const ListingFormError(message: 'Description must be at least 15 characters.'));
      return;
    }
    if (imageFiles.isEmpty) {
      emit(const ListingFormError(message: 'At least one image is required.'));
      return;
    }
    if (listingType == ListingType.rental) {
      if (pricePerDay == null || pricePerDay <= 0) {
        emit(const ListingFormError(message: 'Valid price per day is required.'));
        return;
      }
    } else {
      if (startingRate == null || startingRate <= 0) {
        emit(const ListingFormError(message: 'Valid starting rate is required.'));
        return;
      }
    }

    emit(const ListingFormUploading(progress: 0.2));

    final entity = ListingEntity(
      id: '', // Will be generated
      ownerId: ownerId,
      ownerDisplayName: ownerDisplayName,
      ownerPhotoUrl: ownerPhotoUrl,
      ownerTrustScore: 5.0, // Default trust score
      listingType: listingType,
      categoryId: categoryId,
      categoryName: categoryName,
      title: title.trim(),
      description: description.trim(),
      status: ListingStatus.available, // MVP skips moderation
      images: const [], // Will be updated during repository upload
      thumbnailUrl: '', // Will be updated during repository upload
      pricePerDay: pricePerDay,
      securityDeposit: securityDeposit,
      startingRate: startingRate,
      rateUnit: rateUnit,
      pickupRadiusKm: pickupRadiusKm,
      location: location,
      geohash: geohash,
      tags: tags,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    emit(const ListingFormSubmitting());

    final result = await repository.createListing(entity, imageFiles);

    result.fold(
      (failure) => emit(ListingFormError(message: failure.message)),
      (listingId) => emit(ListingFormSuccess(listingId: listingId)),
    );
  }
}
