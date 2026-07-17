import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:local_first/features/listings/data/models/category_model.dart';
import 'package:local_first/features/listings/data/models/listing_model.dart';
import 'package:local_first/features/listings/domain/entities/listing_entity.dart';

abstract class DiscoveryRemoteDatasource {
  /// Fetch all listing categories ordered by sortOrder.
  Future<List<CategoryModel>> fetchCategories();

  /// Query listings within a specific geospatial radius and filter results.
  Future<List<ListingModel>> fetchListingsByRadius({
    required GeoPoint center,
    required double radiusKm,
    ListingType? type,
    String? categoryId,
    double? minTrustScore,
    int limit = 20,
  });

  /// Read a single listing document from the listings collection by ID.
  Future<ListingModel> fetchListingById(String id);
}

class DiscoveryRemoteDatasourceImpl implements DiscoveryRemoteDatasource {
  final FirebaseFirestore firestore;

  DiscoveryRemoteDatasourceImpl({required this.firestore});

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    final snapshot = await firestore
        .collection('categories')
        .orderBy('sortOrder')
        .get();
    return snapshot.docs
        .map((doc) => CategoryModel.fromJson(doc.data(), id: doc.id))
        .toList();
  }

  @override
  Future<List<ListingModel>> fetchListingsByRadius({
    required GeoPoint center,
    required double radiusKm,
    ListingType? type,
    String? categoryId,
    double? minTrustScore,
    int limit = 20,
  }) async {
    final collectionReference = firestore.collection('listings');
    final geoCollectionRef = GeoCollectionReference<Map<String, dynamic>>(collectionReference);

    final centerPoint = GeoFirePoint(center);

    // geoflutterfire_plus query within the geographical radius
    final documents = await geoCollectionRef.fetchWithin(
      center: centerPoint,
      radiusInKm: radiusKm,
      field: 'location',
      geopointFrom: (data) {
        final loc = data['location'];
        if (loc is Map) {
          return loc['geopoint'] as GeoPoint? ?? const GeoPoint(0, 0);
        } else if (loc is GeoPoint) {
          return loc;
        }
        return const GeoPoint(0, 0);
      },
    );

    final List<ListingModel> results = [];
    for (final doc in documents) {
      final data = doc.data();
      if (data == null) continue;

      final model = ListingModel.fromJson(data, id: doc.id);

      // Filter: status == 'available'
      if (model.status != ListingStatus.available) continue;

      // Filter: listingType
      if (type != null && model.listingType != type) continue;

      // Filter: categoryId
      if (categoryId != null && model.categoryId != categoryId) continue;

      // Filter: minTrustScore
      if (minTrustScore != null && model.ownerTrustScore < minTrustScore) continue;

      results.add(model);

      if (results.length >= limit) {
        break;
      }
    }

    return results;
  }

  @override
  Future<ListingModel> fetchListingById(String id) async {
    final doc = await firestore.collection('listings').doc(id).get();
    if (!doc.exists || doc.data() == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
        message: 'Listing with id $id not found',
      );
    }
    return ListingModel.fromJson(doc.data()!, id: doc.id);
  }
}
