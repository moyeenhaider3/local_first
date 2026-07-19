import 'package:equatable/equatable.dart';

/// Represents the status of an escrow hold in Local First.
enum EscrowStatus {
  /// Funds are currently held securely in escrow.
  held,

  /// Escrow funds have been successfully released to the owner.
  releasedToOwner,

  /// Escrow funds have been refunded back to the renter.
  refundedToRenter,

  /// Escrow is frozen pending dispute resolution.
  disputeFrozen,
}

/// Domain entity representing an escrow hold record in Local First.
class EscrowEntity extends Equatable {
  /// Unique identifier of the escrow record.
  final String id;

  /// Associated rental agreement ID.
  final String agreementId;

  /// Total funds currently locked in escrow.
  final double totalHeld;

  /// Current status of the escrow hold.
  final EscrowStatus status;

  /// Timestamp when the funds were locked in escrow.
  final DateTime heldAt;

  /// Timestamp when the escrow was resolved or released, if applicable.
  final DateTime? resolvedAt;

  /// Creates an [EscrowEntity] instance.
  const EscrowEntity({
    required this.id,
    required this.agreementId,
    required this.totalHeld,
    required this.status,
    required this.heldAt,
    this.resolvedAt,
  });

  @override
  List<Object?> get props => [
        id,
        agreementId,
        totalHeld,
        status,
        heldAt,
        resolvedAt,
      ];
}
