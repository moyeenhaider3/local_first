import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:local_first/core/error/failures.dart';
import 'package:local_first/features/listings/domain/entities/category_entity.dart';
import 'package:local_first/features/listings/domain/entities/listing_entity.dart';

abstract class DiscoveryRepository {
  /// Fetch categories with optional cache bypass [forceRefresh].
  Future<Either<Failure, List<CategoryEntity>>> getCategories({bool forceRefresh = false});

  /// Fetch listings within a specified radius with optional filtering and [forceRefresh].
  Future<Either<Failure, List<ListingEntity>>> getListingsByRadius({
    required GeoPoint center,
    required double radiusKm,
    ListingType? type,
    String? categoryId,
    double? minTrustScore,
    bool forceRefresh = false,
  });

  /// Direct retrieval of a single listing document by ID (no cache).
  Future<Either<Failure, ListingEntity>> getListingById(String id);

  /// Publish/create a new marketplace listing.
  Future<Either<Failure, String>> createListing(ListingEntity entity, List<dynamic> imageFiles);
}
