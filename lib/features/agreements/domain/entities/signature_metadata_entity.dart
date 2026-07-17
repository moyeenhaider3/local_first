import 'package:equatable/equatable.dart';

/// Domain Layer: Signature Metadata Entity
/// Captures digital signature context including user consent details,
/// device metadata, and verification state.
class SignatureMetadataEntity extends Equatable {
  final String fullName;
  final String phone;
  final DateTime timestamp;
  final String? kycSnapshotRef;
  final String? deviceInfo;
  final String? appVersion;
  final String? ipAddress;
  final String? deviceFingerprint;

  const SignatureMetadataEntity({
    required this.fullName,
    required this.phone,
    required this.timestamp,
    this.kycSnapshotRef,
    this.deviceInfo,
    this.appVersion,
    this.ipAddress,
    this.deviceFingerprint,
  });

  /// Converts this entity to a map for Cloud Function JSON submission.
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phone': phone,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'kycSnapshotRef': kycSnapshotRef,
      'deviceInfo': deviceInfo,
      'appVersion': appVersion,
      'ipAddress': ipAddress,
      'deviceFingerprint': deviceFingerprint,
    };
  }

  /// Factory to load from map.
  factory SignatureMetadataEntity.fromJson(Map<String, dynamic> json) {
    return SignatureMetadataEntity(
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      timestamp: json['timestamp'] != null 
          ? (json['timestamp'] is String 
              ? DateTime.parse(json['timestamp'] as String) 
              : json['timestamp'] as DateTime)
          : DateTime.now(),
      kycSnapshotRef: json['kycSnapshotRef'] as String?,
      deviceInfo: json['deviceInfo'] as String?,
      appVersion: json['appVersion'] as String?,
      ipAddress: json['ipAddress'] as String?,
      deviceFingerprint: json['deviceFingerprint'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        fullName,
        phone,
        timestamp,
        kycSnapshotRef,
        deviceInfo,
        appVersion,
        ipAddress,
        deviceFingerprint,
      ];
}
