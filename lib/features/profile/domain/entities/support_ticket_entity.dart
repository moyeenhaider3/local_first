import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// PROFILE feature - Domain Layer: Support Ticket Entity
/// Business entity representing a user support or helpdesk request in Local First.
class SupportTicketEntity extends Equatable {
  /// Unique support ticket ID.
  final String id;

  /// User ID of the user submitting the ticket.
  final String userId;

  /// Display name or email of the submitter.
  final String userName;

  /// Brief subject or issue title.
  final String subject;

  /// Ticket category (e.g., 'billing', 'verification', 'damage_dispute', 'general').
  final String category;

  /// Detailed description of the issue or feedback.
  final String description;

  /// Ticket lifecycle status: 'open', 'in_progress', 'resolved', 'closed'.
  final String status;

  /// Priority level: 'low', 'medium', 'high', 'urgent'.
  final String priority;

  /// Ticket creation timestamp.
  final DateTime createdAt;

  /// Ticket last update timestamp.
  final DateTime? updatedAt;

  /// Creates a [SupportTicketEntity] instance.
  const SupportTicketEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.subject,
    required this.category,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor to deserialize from a Firestore DocumentSnapshot.
  factory SupportTicketEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final createdRaw = data['createdAt'];
    final DateTime createdDate = createdRaw is Timestamp
        ? createdRaw.toDate()
        : (createdRaw is String ? DateTime.tryParse(createdRaw) ?? DateTime.now() : DateTime.now());

    final updatedRaw = data['updatedAt'];
    final DateTime? updatedDate = updatedRaw is Timestamp
        ? updatedRaw.toDate()
        : (updatedRaw is String ? DateTime.tryParse(updatedRaw) : null);

    return SupportTicketEntity(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'User',
      subject: data['subject'] as String? ?? '',
      category: data['category'] as String? ?? 'general',
      description: data['description'] as String? ?? '',
      status: data['status'] as String? ?? 'open',
      priority: data['priority'] as String? ?? 'medium',
      createdAt: createdDate,
      updatedAt: updatedDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        subject,
        category,
        description,
        status,
        priority,
        createdAt,
        updatedAt,
      ];
}
