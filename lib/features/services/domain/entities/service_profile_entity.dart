import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:local_first/features/services/domain/entities/worker_availability.dart';

/// SERVICES feature - Domain Layer: Service Profile Entity
/// Business entity representing a registered service worker profile in Local First.
class ServiceProfileEntity extends Equatable {
  /// Unique identifier of the user (corresponds to profiles/{userId}).
  final String userId;

  /// Full display name of the worker.
  final String displayName;

  /// Optional profile picture URL.
  final String? photoUrl;

  /// Contact phone number of the worker.
  final String phone;

  /// Primary skill identifier for category indexing.
  final String primarySkillId;

  /// Human-readable name of the primary skill.
  final String primarySkillName;

  /// List of all skill tag labels registered by the worker.
  final List<String> skills;

  /// Starting rate price for services offered.
  final double startingRate;

  /// Rate unit ('per hour', 'per day', 'per job').
  final String rateUnit;

  /// Current availability state of the worker.
  final WorkerAvailability availabilityStatus;

  /// Service coverage radius in kilometers.
  final double serviceRadiusKm;

  /// Geographic coordinates of the worker base location.
  final GeoPoint location;

  /// Geohash string for spatial indexing.
  final String geohash;

  /// Description of experience or background.
  final String? experience;

  /// Business or trade name (if applicable).
  final String? businessName;

  /// Type of provider organization (individual, team, business).
  final ProviderType providerType;

  /// Number of team members (if providerType is team).
  final int? teamSize;

  /// Trust score rating (0.0 - 5.0).
  final double trustScore;

  /// Total count of completed reviews.
  final int totalReviews;

  /// Indicates if the worker's KYC identity is verified.
  final bool isKycVerified;

  /// Creates a [ServiceProfileEntity] instance.
  const ServiceProfileEntity({
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.phone,
    required this.primarySkillId,
    required this.primarySkillName,
    required this.skills,
    required this.startingRate,
    this.rateUnit = 'per hour',
    this.availabilityStatus = WorkerAvailability.availableNow,
    required this.serviceRadiusKm,
    required this.location,
    required this.geohash,
    this.experience,
    this.businessName,
    this.providerType = ProviderType.individual,
    this.teamSize,
    this.trustScore = 0.0,
    this.totalReviews = 0,
    this.isKycVerified = false,
  });

  /// Creates a modified copy of this [ServiceProfileEntity].
  ServiceProfileEntity copyWith({
    String? userId,
    String? displayName,
    String? photoUrl,
    String? phone,
    String? primarySkillId,
    String? primarySkillName,
    List<String>? skills,
    double? startingRate,
    String? rateUnit,
    WorkerAvailability? availabilityStatus,
    double? serviceRadiusKm,
    GeoPoint? location,
    String? geohash,
    String? experience,
    String? businessName,
    ProviderType? providerType,
    int? teamSize,
    double? trustScore,
    int? totalReviews,
    bool? isKycVerified,
  }) {
    return ServiceProfileEntity(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      primarySkillId: primarySkillId ?? this.primarySkillId,
      primarySkillName: primarySkillName ?? this.primarySkillName,
      skills: skills ?? this.skills,
      startingRate: startingRate ?? this.startingRate,
      rateUnit: rateUnit ?? this.rateUnit,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      serviceRadiusKm: serviceRadiusKm ?? this.serviceRadiusKm,
      location: location ?? this.location,
      geohash: geohash ?? this.geohash,
      experience: experience ?? this.experience,
      businessName: businessName ?? this.businessName,
      providerType: providerType ?? this.providerType,
      teamSize: teamSize ?? this.teamSize,
      trustScore: trustScore ?? this.trustScore,
      totalReviews: totalReviews ?? this.totalReviews,
      isKycVerified: isKycVerified ?? this.isKycVerified,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        displayName,
        photoUrl,
        phone,
        primarySkillId,
        primarySkillName,
        skills,
        startingRate,
        rateUnit,
        availabilityStatus,
        serviceRadiusKm,
        location,
        geohash,
        experience,
        businessName,
        providerType,
        teamSize,
        trustScore,
        totalReviews,
        isKycVerified,
      ];
}
