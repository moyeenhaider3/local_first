import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_first/features/services/domain/entities/service_profile_entity.dart';
import 'package:local_first/features/services/domain/entities/worker_availability.dart';

/// SERVICES feature - Data Layer: Service Profile Model
/// Data transfer model for worker profiles stored in profiles/{userId}.
class ServiceProfileModel extends ServiceProfileEntity {
  /// Creates a [ServiceProfileModel] instance.
  const ServiceProfileModel({
    required super.userId,
    required super.displayName,
    super.photoUrl,
    required super.phone,
    required super.primarySkillId,
    required super.primarySkillName,
    required super.skills,
    required super.startingRate,
    super.rateUnit,
    super.availabilityStatus,
    required super.serviceRadiusKm,
    required super.location,
    required super.geohash,
    super.experience,
    super.businessName,
    super.providerType,
    super.teamSize,
    super.trustScore,
    super.totalReviews,
    super.isKycVerified,
  });

  /// Factory constructor to deserialize Firestore DocumentSnapshot.
  factory ServiceProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ServiceProfileModel.fromMap(data, doc.id);
  }

  /// Factory constructor to deserialize Map json data.
  factory ServiceProfileModel.fromMap(Map<String, dynamic> map, String id) {
    final rawSkills = map['skills'];
    final List<String> skillsList = rawSkills is List
        ? rawSkills.map((e) => e.toString()).toList()
        : <String>[];

    final locRaw = map['location'];
    GeoPoint locationPoint = const GeoPoint(0.0, 0.0);
    if (locRaw is GeoPoint) {
      locationPoint = locRaw;
    } else if (locRaw is Map) {
      final lat = (locRaw['latitude'] as num?)?.toDouble() ?? 0.0;
      final lng = (locRaw['longitude'] as num?)?.toDouble() ?? 0.0;
      locationPoint = GeoPoint(lat, lng);
    }

    return ServiceProfileModel(
      userId: id,
      displayName: map['displayName'] as String? ?? 'Service Provider',
      photoUrl: map['photoUrl'] as String?,
      phone: map['phone'] as String? ?? '',
      primarySkillId: map['primarySkillId'] as String? ?? 'general',
      primarySkillName: map['primarySkillName'] as String? ?? 'General Services',
      skills: skillsList,
      startingRate: (map['startingRate'] as num?)?.toDouble() ?? 0.0,
      rateUnit: map['rateUnit'] as String? ?? 'per hour',
      availabilityStatus: WorkerAvailabilityX.fromCode(map['availabilityStatus'] as String?),
      serviceRadiusKm: (map['serviceRadiusKm'] as num?)?.toDouble() ?? 10.0,
      location: locationPoint,
      geohash: map['geohash'] as String? ?? '',
      experience: map['experience'] as String?,
      businessName: map['businessName'] as String?,
      providerType: ProviderTypeX.fromCode(map['providerType'] as String?),
      teamSize: (map['teamSize'] as num?)?.toInt(),
      trustScore: (map['trustScore'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (map['totalReviews'] as num?)?.toInt() ?? 0,
      isKycVerified: map['isKycVerified'] as bool? ?? map['verificationStatus'] == 'verified',
    );
  }

  /// Factory constructor to convert from [ServiceProfileEntity].
  factory ServiceProfileModel.fromEntity(ServiceProfileEntity entity) {
    return ServiceProfileModel(
      userId: entity.userId,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      phone: entity.phone,
      primarySkillId: entity.primarySkillId,
      primarySkillName: entity.primarySkillName,
      skills: entity.skills,
      startingRate: entity.startingRate,
      rateUnit: entity.rateUnit,
      availabilityStatus: entity.availabilityStatus,
      serviceRadiusKm: entity.serviceRadiusKm,
      location: entity.location,
      geohash: entity.geohash,
      experience: entity.experience,
      businessName: entity.businessName,
      providerType: entity.providerType,
      teamSize: entity.teamSize,
      trustScore: entity.trustScore,
      totalReviews: entity.totalReviews,
      isKycVerified: entity.isKycVerified,
    );
  }

  /// Serializes model to Map for Firestore document creation/updates.
  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phone': phone,
      'primarySkillId': primarySkillId,
      'primarySkillName': primarySkillName,
      'skills': skills,
      'startingRate': startingRate,
      'rateUnit': rateUnit,
      'availabilityStatus': availabilityStatus.toCode(),
      'serviceRadiusKm': serviceRadiusKm,
      'location': location,
      'geohash': geohash,
      'experience': experience,
      'businessName': businessName,
      'providerType': providerType.toCode(),
      'teamSize': teamSize,
      'trustScore': trustScore,
      'totalReviews': totalReviews,
      'isKycVerified': isKycVerified,
      'roles': {
        'worker': true,
      },
    };
  }
}
