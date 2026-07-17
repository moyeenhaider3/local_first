import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:local_first/features/auth/domain/entities/user_entity.dart';

/// AUTH feature - Data Layer: User Model
/// Serializable representation of the user document (users/{userId}).
class UserModel extends Equatable {
  final String userId;
  final String phone;
  final String? displayName;
  final String? photoUrl;
  final Map<String, bool> roles;
  final String verificationStatus;
  final String? kycDocumentUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.userId,
    required this.phone,
    this.displayName,
    this.photoUrl,
    this.roles = const {
      'renter': false,
      'owner': false,
      'customer': false,
      'worker': false,
    },
    this.verificationStatus = 'unverified',
    this.kycDocumentUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      userId: entity.userId,
      phone: entity.phone,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      roles: entity.roles,
      verificationStatus: entity.verificationStatus,
      kycDocumentUrl: entity.kycDocumentUrl,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json, {required String userId}) {
    final rolesRaw = json['roles'];
    final Map<String, bool> roles = {
      'renter': false,
      'owner': false,
      'customer': false,
      'worker': false,
    };
    if (rolesRaw is Map) {
      rolesRaw.forEach((key, value) {
        if (key is String && value is bool) {
          roles[key] = value;
        }
      });
    }

    final created = json['createdAt'];
    final updated = json['updatedAt'];

    return UserModel(
      userId: userId,
      phone: json['phone'] as String? ?? '',
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      roles: roles,
      verificationStatus: json['verificationStatus'] as String? ?? 'unverified',
      kycDocumentUrl: json['kycDocumentUrl'] as String?,
      createdAt: created is Timestamp ? created.toDate() : null,
      updatedAt: updated is Timestamp ? updated.toDate() : null,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      phone: phone,
      displayName: displayName,
      photoUrl: photoUrl,
      roles: roles,
      verificationStatus: verificationStatus,
      kycDocumentUrl: kycDocumentUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'roles': roles,
      'verificationStatus': verificationStatus,
      'kycDocumentUrl': kycDocumentUrl,
    };
  }

  /// Payload written on creation (server timestamps for audit fields).
  Map<String, dynamic> toCreateJson() {
    return {
      ...toJson(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Payload written on update (refreshes updatedAt).
  Map<String, dynamic> toUpdateJson() {
    return {
      ...toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  List<Object?> get props => [
        userId,
        phone,
        displayName,
        photoUrl,
        roles,
        verificationStatus,
        kycDocumentUrl,
        createdAt,
        updatedAt,
      ];
}
