/// SERVICES feature - Domain Layer: Worker Availability & Provider Types
/// Enums representing availability state and business structure of local service providers in Local First.
library;

/// Worker availability state (§16.3 business rules).
enum WorkerAvailability {
  /// Worker is currently available for immediate dispatch or contact.
  availableNow,

  /// Worker is available for bookings today.
  availableToday,

  /// Worker is available for bookings during the current week.
  availableThisWeek,

  /// Worker accepts bookings by prior appointment only.
  byAppointment,

  /// Worker is currently busy with ongoing tasks.
  busy,

  /// Worker is temporarily on leave.
  onLeave,

  /// Worker profile is inactive.
  inactive,
}

/// Helper extension on [WorkerAvailability] for string serialization.
extension WorkerAvailabilityX on WorkerAvailability {
  /// Converts [WorkerAvailability] enum to Firestore string code.
  String toCode() {
    switch (this) {
      case WorkerAvailability.availableNow:
        return 'AVAILABLE_NOW';
      case WorkerAvailability.availableToday:
        return 'AVAILABLE_TODAY';
      case WorkerAvailability.availableThisWeek:
        return 'AVAILABLE_THIS_WEEK';
      case WorkerAvailability.byAppointment:
        return 'BY_APPOINTMENT';
      case WorkerAvailability.busy:
        return 'BUSY';
      case WorkerAvailability.onLeave:
        return 'ON_LEAVE';
      case WorkerAvailability.inactive:
        return 'INACTIVE';
    }
  }

  /// Parses Firestore string code to [WorkerAvailability] enum.
  static WorkerAvailability fromCode(String? code) {
    switch (code) {
      case 'AVAILABLE_NOW':
        return WorkerAvailability.availableNow;
      case 'AVAILABLE_TODAY':
        return WorkerAvailability.availableToday;
      case 'AVAILABLE_THIS_WEEK':
        return WorkerAvailability.availableThisWeek;
      case 'BY_APPOINTMENT':
        return WorkerAvailability.byAppointment;
      case 'BUSY':
        return WorkerAvailability.busy;
      case 'ON_LEAVE':
        return WorkerAvailability.onLeave;
      case 'INACTIVE':
      default:
        return WorkerAvailability.inactive;
    }
  }
}

/// Provider organization type (§12.2 business rules).
enum ProviderType {
  /// Individual solo worker.
  individual,

  /// Small team or group of workers.
  team,

  /// Registered business or company.
  business,
}

/// Helper extension on [ProviderType] for string serialization.
extension ProviderTypeX on ProviderType {
  /// Converts [ProviderType] enum to string.
  String toCode() {
    return name;
  }

  /// Parses string to [ProviderType] enum.
  static ProviderType fromCode(String? code) {
    switch (code?.toLowerCase()) {
      case 'team':
        return ProviderType.team;
      case 'business':
        return ProviderType.business;
      case 'individual':
      default:
        return ProviderType.individual;
    }
  }
}
