part of 'discovery_cubit.dart';

/// Presentation Layer: Discovery Filters Value Object.
class DiscoveryFilters extends Equatable {
  final ListingType? listingType;
  final String? categoryId;
  final double radiusKm;
  final double? minTrustScore;
  final String? searchQuery;

  const DiscoveryFilters({
    this.listingType,
    this.categoryId,
    this.radiusKm = 5.0,
    this.minTrustScore,
    this.searchQuery,
  });

  DiscoveryFilters copyWith({
    ListingType? Function()? listingType,
    String? Function()? categoryId,
    double? radiusKm,
    double? Function()? minTrustScore,
    String? Function()? searchQuery,
  }) {
    return DiscoveryFilters(
      listingType: listingType != null ? listingType() : this.listingType,
      categoryId: categoryId != null ? categoryId() : this.categoryId,
      radiusKm: radiusKm ?? this.radiusKm,
      minTrustScore: minTrustScore != null ? minTrustScore() : this.minTrustScore,
      searchQuery: searchQuery != null ? searchQuery() : this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        listingType,
        categoryId,
        radiusKm,
        minTrustScore,
        searchQuery,
      ];
}

/// Presentation Layer: Sealed Discovery State.
sealed class DiscoveryState extends Equatable {
  const DiscoveryState();

  @override
  List<Object?> get props => [];
}

final class DiscoveryInitial extends DiscoveryState {
  const DiscoveryInitial();
}

final class DiscoveryLoading extends DiscoveryState {
  const DiscoveryLoading();
}

final class DiscoveryLoaded extends DiscoveryState {
  final List<ListingEntity> listings;
  final List<CategoryEntity> categories;
  final DiscoveryFilters activeFilters;

  const DiscoveryLoaded({
    required this.listings,
    required this.categories,
    required this.activeFilters,
  });

  @override
  List<Object?> get props => [listings, categories, activeFilters];
}

final class DiscoveryEmpty extends DiscoveryState {
  final DiscoveryFilters activeFilters;

  const DiscoveryEmpty({
    required this.activeFilters,
  });

  @override
  List<Object?> get props => [activeFilters];
}

final class DiscoveryError extends DiscoveryState {
  final String message;

  const DiscoveryError(this.message);

  @override
  List<Object?> get props => [message];
}
