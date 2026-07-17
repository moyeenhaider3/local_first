import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ListingType { rental, service }

enum ListingStatus { available, reserved, rented, paused, removed }

/// Domain Layer: Listing Entity.
/// Represents a unified marketplace listing for both rentable items and service workers.
class ListingEntity extends Equatable {
  final String id;
  final String ownerId;
  final String ownerDisplayName;
  final String? ownerPhotoUrl;
  final double ownerTrustScore;
  final ListingType listingType;
  final String categoryId;
  final String categoryName;
  final String title;
  final String description;
  final ListingStatus status;
  final List<String> images;
  final String thumbnailUrl;
  final double? pricePerDay;
  final double? securityDeposit;
  final double? startingRate;
  final String? rateUnit;
  final double pickupRadiusKm;
  final GeoPoint location;
  final String geohash;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ListingEntity({
    required this.id,
    required this.ownerId,
    required this.ownerDisplayName,
    this.ownerPhotoUrl,
    required this.ownerTrustScore,
    required this.listingType,
    required this.categoryId,
    required this.categoryName,
    required this.title,
    required this.description,
    required this.status,
    required this.images,
    required this.thumbnailUrl,
    this.pricePerDay,
    this.securityDeposit,
    this.startingRate,
    this.rateUnit,
    required this.pickupRadiusKm,
    required this.location,
    required this.geohash,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        ownerId,
        ownerDisplayName,
        ownerPhotoUrl,
        ownerTrustScore,
        listingType,
        categoryId,
        categoryName,
        title,
        description,
        status,
        images,
        thumbnailUrl,
        pricePerDay,
        securityDeposit,
        startingRate,
        rateUnit,
        pickupRadiusKm,
        location,
        geohash,
        tags,
        createdAt,
        updatedAt,
      ];
}
