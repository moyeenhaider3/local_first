import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:local_first/core/cache/cache_manager.dart';
import 'package:local_first/core/error/failures.dart';
import 'package:local_first/features/listings/data/datasources/discovery_remote_datasource.dart';
import 'package:local_first/features/listings/data/models/listing_model.dart';
import 'package:local_first/features/listings/domain/entities/category_entity.dart';
import 'package:local_first/features/listings/domain/entities/listing_entity.dart';
import 'package:local_first/features/listings/domain/repositories/discovery_repository.dart';

class DiscoveryRepositoryImpl implements DiscoveryRepository {
  final DiscoveryRemoteDatasource remoteDatasource;
  final CacheManager<List<CategoryEntity>> categoriesCache;
  final CacheManager<List<ListingEntity>> listingsCache;

  DiscoveryRepositoryImpl({
    required this.remoteDatasource,
    required this.categoriesCache,
    required this.listingsCache,
  });

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories({bool forceRefresh = false}) async {
    const cacheKey = 'categories_all';
    if (!forceRefresh) {
      final cached = categoriesCache.get(cacheKey);
      if (cached != null) {
        return Right(cached);
      }
    }

    try {
      final models = await remoteDatasource.fetchCategories();
      final entities = models.map((m) => m.toEntity()).toList();
      // Cache categories for 1 hour as they are static/rarely updated
      categoriesCache.put(cacheKey, entities, ttl: const Duration(hours: 1));
      return Right(entities);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to fetch categories from Firestore.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ListingEntity>>> getListingsByRadius({
    required GeoPoint center,
    required double radiusKm,
    ListingType? type,
    String? categoryId,
    double? minTrustScore,
    bool forceRefresh = false,
  }) async {
    // Standardize lat/lng to 4 decimal places (~11 meters) to stabilize cache keys.
    final latKey = center.latitude.toStringAsFixed(4);
    final lngKey = center.longitude.toStringAsFixed(4);
    final cacheKey = '${latKey}_${lngKey}_${radiusKm}_${type?.name ?? "all"}_${categoryId ?? "all"}_${minTrustScore ?? "all"}';

    if (!forceRefresh) {
      final cached = listingsCache.get(cacheKey);
      if (cached != null) {
        return Right(cached);
      }
    }

    try {
      final models = await remoteDatasource.fetchListingsByRadius(
        center: center,
        radiusKm: radiusKm,
        type: type,
        categoryId: categoryId,
        minTrustScore: minTrustScore,
      );
      final entities = models.map((m) => m.toEntity()).toList();
      listingsCache.put(cacheKey, entities, ttl: const Duration(minutes: 5));
      return Right(entities);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to query listings by radius.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ListingEntity>> getListingById(String id) async {
    try {
      final model = await remoteDatasource.fetchListingById(id);
      return Right(model.toEntity());
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to read listing.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createListing(ListingEntity entity, List<dynamic> imageFiles) async {
    try {
      final listingId = remoteDatasource.generateListingId();
      final imageUrls = await remoteDatasource.uploadListingImages(listingId, imageFiles);
      final thumbnailUrl = imageUrls.isNotEmpty ? imageUrls.first : '';

      final model = ListingModel(
        id: listingId,
        ownerId: entity.ownerId,
        ownerDisplayName: entity.ownerDisplayName,
        ownerPhotoUrl: entity.ownerPhotoUrl,
        ownerTrustScore: entity.ownerTrustScore,
        listingType: entity.listingType,
        categoryId: entity.categoryId,
        categoryName: entity.categoryName,
        title: entity.title,
        description: entity.description,
        status: entity.status,
        images: imageUrls,
        thumbnailUrl: thumbnailUrl,
        pricePerDay: entity.pricePerDay,
        securityDeposit: entity.securityDeposit,
        startingRate: entity.startingRate,
        rateUnit: entity.rateUnit,
        pickupRadiusKm: entity.pickupRadiusKm,
        location: entity.location,
        geohash: entity.geohash,
        tags: entity.tags,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );

      await remoteDatasource.createListing(model);
      return Right(listingId);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to create listing.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
