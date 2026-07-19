import 'package:equatable/equatable.dart';

/// SERVICES feature - Domain Layer: Service Request Status
/// Lifecycle status of a hire service request.
enum ServiceRequestStatus {
  /// Pending worker acceptance.
  pending,

  /// Worker accepted the hire request.
  accepted,

  /// Worker rejected the hire request.
  rejected,

  /// Job is currently in progress.
  inProgress,

  /// Service completed successfully.
  completed,

  /// Request cancelled by customer or worker.
  cancelled,
}

/// Helper extension on [ServiceRequestStatus] for serialization.
extension ServiceRequestStatusX on ServiceRequestStatus {
  /// Converts [ServiceRequestStatus] enum to string.
  String toCode() => name;

  /// Parses string to [ServiceRequestStatus] enum.
  static ServiceRequestStatus fromCode(String? code) {
    switch (code?.toLowerCase()) {
      case 'accepted':
        return ServiceRequestStatus.accepted;
      case 'rejected':
        return ServiceRequestStatus.rejected;
      case 'inprogress':
      case 'in_progress':
        return ServiceRequestStatus.inProgress;
      case 'completed':
        return ServiceRequestStatus.completed;
      case 'cancelled':
        return ServiceRequestStatus.cancelled;
      case 'pending':
      default:
        return ServiceRequestStatus.pending;
    }
  }
}

/// SERVICES feature - Domain Layer: Service Request Entity
/// Business entity representing a service request / hire offer in Local First.
class ServiceRequestEntity extends Equatable {
  /// Unique request identifier.
  final String id;

  /// Worker identifier.
  final String workerId;

  /// Worker name.
  final String workerName;

  /// Customer identifier.
  final String customerId;

  /// Customer name.
  final String customerName;

  /// Detailed description of the job requested.
  final String jobDescription;

  /// Scheduled date/time for service execution.
  final DateTime scheduledDate;

  /// Estimated rate amount for the requested job.
  final double estimatedRate;

  /// Unit for estimated rate ('per hour', 'per day', 'per job').
  final String rateUnit;

  /// Current lifecycle status.
  final ServiceRequestStatus status;

  /// Request creation timestamp.
  final DateTime createdAt;

  /// Creates a [ServiceRequestEntity] instance.
  const ServiceRequestEntity({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.customerId,
    required this.customerName,
    required this.jobDescription,
    required this.scheduledDate,
    required this.estimatedRate,
    this.rateUnit = 'per hour',
    this.status = ServiceRequestStatus.pending,
    required this.createdAt,
  });

  /// Creates a modified copy of this [ServiceRequestEntity].
  ServiceRequestEntity copyWith({
    String? id,
    String? workerId,
    String? workerName,
    String? customerId,
    String? customerName,
    String? jobDescription,
    DateTime? scheduledDate,
    double? estimatedRate,
    String? rateUnit,
    ServiceRequestStatus? status,
    DateTime? createdAt,
  }) {
    return ServiceRequestEntity(
      id: id ?? this.id,
      workerId: workerId ?? this.workerId,
      workerName: workerName ?? this.workerName,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      jobDescription: jobDescription ?? this.jobDescription,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      estimatedRate: estimatedRate ?? this.estimatedRate,
      rateUnit: rateUnit ?? this.rateUnit,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workerId,
        workerName,
        customerId,
        customerName,
        jobDescription,
        scheduledDate,
        estimatedRate,
        rateUnit,
        status,
        createdAt,
      ];
}
