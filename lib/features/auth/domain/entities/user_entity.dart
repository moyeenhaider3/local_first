import 'package:equatable/equatable.dart';

/// AUTH feature - Domain Layer: User Entity
/// Core business object representing a verified user identity.
class UserEntity extends Equatable {
  final String userId;
  final String phone;
  final String? displayName;
  final String? photoUrl;
  final Map<String, bool> roles;
  final String verificationStatus;
  final String? kycDocumentUrl;
  final String? adminRole;
  final String? kycRemarks;

  const UserEntity({
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
    this.adminRole,
    this.kycRemarks,
  });

  bool get isAdmin => adminRole == 'admin' || adminRole == 'superadmin';
  bool get isSuperAdmin => adminRole == 'superadmin';
  bool get hasAdminAccess => isAdmin;

  UserEntity copyWith({
    String? userId,
    String? phone,
    String? displayName,
    String? photoUrl,
    Map<String, bool>? roles,
    String? verificationStatus,
    String? kycDocumentUrl,
    String? adminRole,
    String? kycRemarks,
  }) {
    return UserEntity(
      userId: userId ?? this.userId,
      phone: phone ?? this.phone,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      roles: roles ?? this.roles,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      kycDocumentUrl: kycDocumentUrl ?? this.kycDocumentUrl,
      adminRole: adminRole ?? this.adminRole,
      kycRemarks: kycRemarks ?? this.kycRemarks,
    );
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
        adminRole,
        kycRemarks,
      ];
}
