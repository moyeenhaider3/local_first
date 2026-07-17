import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_first/features/listings/domain/entities/category_entity.dart';
import 'package:local_first/features/listings/domain/entities/listing_entity.dart';
import 'package:local_first/features/listings/domain/repositories/discovery_repository.dart';

part 'discovery_state.dart';

/// Presentation Layer: Discovery Cubit.
/// Manages directory searches, filters, map overlay elements, and categories.
class DiscoveryCubit extends Cubit<DiscoveryState> {
  final DiscoveryRepository repository;

  DiscoveryFilters _filters = const DiscoveryFilters();
  GeoPoint? _lastCenter;

  DiscoveryCubit({required this.repository}) : super(const DiscoveryInitial());

  /// Returns the current active filters.
  DiscoveryFilters get filters => _filters;

  /// Returns the last query center point.
  GeoPoint? get lastCenter => _lastCenter;

  /// Loads listings and categories based on active filters and location.
  /// Standard coordinates fallback to a default location if Geolocator is disabled/denied.
  Future<void> loadDiscovery({
    bool forceRefresh = false,
    GeoPoint? customCenter,
  }) async {
    emit(const DiscoveryLoading());

    GeoPoint? center = customCenter ?? _lastCenter;
    if (center == null) {
      try {
        final position = await _determinePosition();
        center = GeoPoint(position.latitude, position.longitude);
      } catch (_) {
        // Fallback to New Delhi coordinates if geolocator is disabled or permission denied
        center = const GeoPoint(28.6139, 77.2090);
      }
    }
    _lastCenter = center;

    // Parallel execution of the two queries
    final categoriesFuture = repository.getCategories(forceRefresh: forceRefresh);
    final listingsFuture = repository.getListingsByRadius(
      center: center,
      radiusKm: _filters.radiusKm,
      type: _filters.listingType,
      categoryId: _filters.categoryId,
      minTrustScore: _filters.minTrustScore,
      forceRefresh: forceRefresh,
    );

    final results = await Future.wait([categoriesFuture, listingsFuture]);
    final categoriesResult = results[0] as Either<dynamic, List<CategoryEntity>>;
    final listingsResult = results[1] as Either<dynamic, List<ListingEntity>>;

    categoriesResult.fold(
      (failure) => emit(DiscoveryError(failure.message)),
      (categories) {
        listingsResult.fold(
          (failure) => emit(DiscoveryError(failure.message)),
          (listings) {
            // Apply search query filter in-memory if query is provided
            final query = _filters.searchQuery;
            List<ListingEntity> filteredListings = listings;
            if (query != null && query.trim().isNotEmpty) {
              final q = query.toLowerCase().trim();
              filteredListings = listings.where((item) {
                final matchTitle = item.title.toLowerCase().contains(q);
                final matchDesc = item.description.toLowerCase().contains(q);
                final matchTags = item.tags.any((t) => t.toLowerCase().contains(q));
                return matchTitle || matchDesc || matchTags;
              }).toList();
            }

            if (filteredListings.isEmpty) {
              emit(DiscoveryEmpty(
                categories: categories,
                activeFilters: _filters,
              ));
            } else {
              emit(DiscoveryLoaded(
                listings: filteredListings,
                categories: categories,
                activeFilters: _filters,
              ));
            }
          },
        );
      },
    );
  }

  /// Updates current filter parameters and triggers a reload.
  Future<void> updateFilters(DiscoveryFilters newFilters) async {
    _filters = newFilters;
    await loadDiscovery();
  }

  /// Reset all filters to default.
  Future<void> clearFilters() async {
    _filters = const DiscoveryFilters();
    await loadDiscovery();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }
}
