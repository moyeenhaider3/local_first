import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:local_first/features/listings/domain/entities/listing_entity.dart';

/// Data Model representing a listing document in Firestore.
class ListingModel extends Equatable {
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

  const ListingModel({
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

  /// Factory to convert a domain entity to a data model.
  factory ListingModel.fromEntity(ListingEntity entity) {
    return ListingModel(
      id: entity.id,
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
      images: entity.images,
      thumbnailUrl: entity.thumbnailUrl,
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
  }

  /// Factory to convert JSON from Firestore to a data model.
  factory ListingModel.fromJson(Map<String, dynamic> json, {required String id}) {
    final locationMap = json['location'];
    GeoPoint loc = const GeoPoint(0, 0);
    String hash = '';

    if (locationMap is Map) {
      loc = locationMap['geopoint'] as GeoPoint? ?? const GeoPoint(0, 0);
      hash = locationMap['geohash'] as String? ?? '';
    } else if (locationMap is GeoPoint) {
      loc = locationMap;
      hash = json['geohash'] as String? ?? '';
    }

    final created = json['createdAt'];
    final updated = json['updatedAt'];

    return ListingModel(
      id: id,
      ownerId: json['ownerId'] as String? ?? '',
      ownerDisplayName: json['ownerDisplayName'] as String? ?? '',
      ownerPhotoUrl: json['ownerPhotoUrl'] as String?,
      ownerTrustScore: (json['ownerTrustScore'] as num?)?.toDouble() ?? 0.0,
      listingType: (json['listingType'] as String?) == 'service'
          ? ListingType.service
          : ListingType.rental,
      categoryId: json['categoryId'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: _parseStatus(json['status'] as String?),
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      pricePerDay: (json['pricePerDay'] as num?)?.toDouble(),
      securityDeposit: (json['securityDeposit'] as num?)?.toDouble(),
      startingRate: (json['startingRate'] as num?)?.toDouble(),
      rateUnit: json['rateUnit'] as String?,
      pickupRadiusKm: (json['pickupRadiusKm'] as num?)?.toDouble() ?? 0.0,
      location: loc,
      geohash: hash,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      createdAt: created is Timestamp
          ? created.toDate()
          : (created is String ? DateTime.parse(created) : DateTime.now()),
      updatedAt: updated is Timestamp
          ? updated.toDate()
          : (updated is String ? DateTime.parse(updated) : DateTime.now()),
    );
  }

  static ListingStatus _parseStatus(String? statusStr) {
    switch (statusStr) {
      case 'reserved':
        return ListingStatus.reserved;
      case 'rented':
        return ListingStatus.rented;
      case 'paused':
        return ListingStatus.paused;
      case 'removed':
        return ListingStatus.removed;
      case 'available':
      default:
        return ListingStatus.available;
    }
  }

  /// Converts this model instance into a domain entity.
  ListingEntity toEntity() {
    return ListingEntity(
      id: id,
      ownerId: ownerId,
      ownerDisplayName: ownerDisplayName,
      ownerPhotoUrl: ownerPhotoUrl,
      ownerTrustScore: ownerTrustScore,
      listingType: listingType,
      categoryId: categoryId,
      categoryName: categoryName,
      title: title,
      description: description,
      status: status,
      images: images,
      thumbnailUrl: thumbnailUrl,
      pricePerDay: pricePerDay,
      securityDeposit: securityDeposit,
      startingRate: startingRate,
      rateUnit: rateUnit,
      pickupRadiusKm: pickupRadiusKm,
      location: location,
      geohash: geohash,
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Converts this model instance to a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'ownerDisplayName': ownerDisplayName,
      'ownerPhotoUrl': ownerPhotoUrl,
      'ownerTrustScore': ownerTrustScore,
      'listingType': listingType.name,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'title': title,
      'description': description,
      'status': status.name,
      'images': images,
      'thumbnailUrl': thumbnailUrl,
      'pricePerDay': pricePerDay,
      'securityDeposit': securityDeposit,
      'startingRate': startingRate,
      'rateUnit': rateUnit,
      'pickupRadiusKm': pickupRadiusKm,
      'location': {
        'geopoint': location,
        'geohash': geohash,
      },
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

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
