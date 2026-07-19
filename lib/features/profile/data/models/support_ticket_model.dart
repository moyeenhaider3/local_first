import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_first/features/profile/domain/entities/support_ticket_entity.dart';

/// PROFILE feature - Data Layer: Support Ticket Model
/// Data model extending [SupportTicketEntity] with serialization logic for Firestore.
class SupportTicketModel extends SupportTicketEntity {
  /// Creates a [SupportTicketModel] instance.
  const SupportTicketModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.subject,
    required super.category,
    required super.description,
    required super.status,
    required super.priority,
    required super.createdAt,
    super.updatedAt,
  });

  /// Factory constructor converting a domain [SupportTicketEntity] to [SupportTicketModel].
  factory SupportTicketModel.fromEntity(SupportTicketEntity entity) {
    return SupportTicketModel(
      id: entity.id,
      userId: entity.userId,
      userName: entity.userName,
      subject: entity.subject,
      category: entity.category,
      description: entity.description,
      status: entity.status,
      priority: entity.priority,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Factory constructor parsing a Firestore DocumentSnapshot into [SupportTicketModel].
  factory SupportTicketModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final createdRaw = data['createdAt'];
    final DateTime createdDate = createdRaw is Timestamp
        ? createdRaw.toDate()
        : (createdRaw is String ? DateTime.tryParse(createdRaw) ?? DateTime.now() : DateTime.now());

    final updatedRaw = data['updatedAt'];
    final DateTime? updatedDate = updatedRaw is Timestamp
        ? updatedRaw.toDate()
        : (updatedRaw is String ? DateTime.tryParse(updatedRaw) : null);

    return SupportTicketModel(
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

  /// Converts this model into a Firestore map structure for writing documents.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'subject': subject,
      'category': category,
      'description': description,
      'status': status,
      'priority': priority,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }
}
