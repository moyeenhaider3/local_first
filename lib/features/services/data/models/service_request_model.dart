import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_first/features/services/domain/entities/service_request_entity.dart';

/// SERVICES feature - Data Layer: Service Request Model
/// Serializable model representing a service request stored in the requests collection.
class ServiceRequestModel extends ServiceRequestEntity {
  /// Creates a [ServiceRequestModel] instance.
  const ServiceRequestModel({
    required super.id,
    required super.workerId,
    required super.workerName,
    required super.customerId,
    required super.customerName,
    required super.jobDescription,
    required super.scheduledDate,
    required super.estimatedRate,
    super.rateUnit,
    super.status,
    required super.createdAt,
  });

  /// Factory constructor to deserialize Firestore DocumentSnapshot.
  factory ServiceRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ServiceRequestModel.fromMap(data, doc.id);
  }

  /// Factory constructor to deserialize Map json data.
  factory ServiceRequestModel.fromMap(Map<String, dynamic> map, String id) {
    final schedRaw = map['scheduledDate'];
    final DateTime schedDate = schedRaw is Timestamp
        ? schedRaw.toDate()
        : (schedRaw is String ? DateTime.tryParse(schedRaw) ?? DateTime.now() : DateTime.now());

    final createdRaw = map['createdAt'];
    final DateTime createdDate = createdRaw is Timestamp
        ? createdRaw.toDate()
        : (createdRaw is String ? DateTime.tryParse(createdRaw) ?? DateTime.now() : DateTime.now());

    return ServiceRequestModel(
      id: id,
      workerId: map['workerId'] as String? ?? map['ownerId'] as String? ?? '',
      workerName: map['workerName'] as String? ?? map['ownerName'] as String? ?? 'Service Worker',
      customerId: map['customerId'] as String? ?? map['renterId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? map['renterName'] as String? ?? 'Customer',
      jobDescription: map['jobDescription'] as String? ?? map['remarks'] as String? ?? '',
      scheduledDate: schedDate,
      estimatedRate: (map['estimatedRate'] as num?)?.toDouble() ?? (map['rate'] as num?)?.toDouble() ?? 0.0,
      rateUnit: map['rateUnit'] as String? ?? 'per hour',
      status: ServiceRequestStatusX.fromCode(map['status'] as String?),
      createdAt: createdDate,
    );
  }

  /// Factory constructor from [ServiceRequestEntity].
  factory ServiceRequestModel.fromEntity(ServiceRequestEntity entity) {
    return ServiceRequestModel(
      id: entity.id,
      workerId: entity.workerId,
      workerName: entity.workerName,
      customerId: entity.customerId,
      customerName: entity.customerName,
      jobDescription: entity.jobDescription,
      scheduledDate: entity.scheduledDate,
      estimatedRate: entity.estimatedRate,
      rateUnit: entity.rateUnit,
      status: entity.status,
      createdAt: entity.createdAt,
    );
  }

  /// Serializes model to Map for Firestore document creation/updates.
  Map<String, dynamic> toMap() {
    return {
      'requestType': 'service',
      'workerId': workerId,
      'workerName': workerName,
      'customerId': customerId,
      'customerName': customerName,
      'jobDescription': jobDescription,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'estimatedRate': estimatedRate,
      'rateUnit': rateUnit,
      'status': status.toCode(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
