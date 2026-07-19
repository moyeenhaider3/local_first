import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_first/features/agreements/presentation/widgets/whatsapp_redirect_bottom_sheet.dart';
import 'package:local_first/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:local_first/features/services/domain/entities/service_request_entity.dart';
import 'package:local_first/features/services/domain/entities/worker_availability.dart';
import 'package:local_first/features/services/presentation/cubits/services_cubit.dart';
import 'package:local_first/features/services/presentation/cubits/services_state.dart';
import 'package:local_first/features/services/presentation/widgets/availability_toggle.dart';
import 'package:local_first/features/services/presentation/widgets/job_card.dart';

/// SERVICES feature - Presentation Layer: Worker Dashboard Page (HIRE-03)
/// Screen for service workers to manage availability toggle and handle incoming service job requests.
class WorkerDashboardPage extends StatefulWidget {
  /// Creates a [WorkerDashboardPage] widget.
  const WorkerDashboardPage({super.key});

  @override
  State<WorkerDashboardPage> createState() => _WorkerDashboardPageState();
}

class _WorkerDashboardPageState extends State<WorkerDashboardPage> {
  WorkerAvailability _currentAvailability = WorkerAvailability.availableNow;

  @override
  void initState() {
    super.initState();
    // Dispatch initial fetch for worker inbound job requests
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInboundJobs();
    });
  }

  /// Helper method loading inbound job requests for current worker.
  void _loadInboundJobs() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      context.read<ServicesCubit>().fetchInboundJobs(authState.uid);
    }
  }

  /// Handles worker availability status toggle update.
  void _onAvailabilityChanged(WorkerAvailability newStatus) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      setState(() {
        _currentAvailability = newStatus;
      });
      context.read<ServicesCubit>().updateAvailability(authState.uid, newStatus);
    }
  }

  /// Handles accepting a service request.
  void _onAcceptJob(ServiceRequestEntity job) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      context.read<ServicesCubit>().acceptJobRequest(job.id, authState.uid);
    }
  }

  /// Handles opening chat/coordination for a job request.
  void _onChatWithCustomer(ServiceRequestEntity job) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) => WhatsAppRedirectBottomSheet(requestId: job.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInboundJobs,
          ),
        ],
      ),
      body: Column(
        children: [
          // Availability Toggle Top Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Work Availability Status',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: AvailabilityToggle(
                    currentStatus: _currentAvailability,
                    onChanged: _onAvailabilityChanged,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Inbound Jobs List
          Expanded(
            child: BlocConsumer<ServicesCubit, ServicesState>(
              listener: (context, state) {
                if (state is AvailabilityUpdated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Status updated to ${_getAvailabilityText(state.status)}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else if (state is ServicesError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ServicesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is InboundJobsLoaded) {
                  final jobs = state.jobs;

                  if (jobs.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async => _loadInboundJobs(),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.work_off_outlined,
                                  size: 64,
                                  color: theme.colorScheme.secondary.withValues(alpha: 0.4),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No inbound job requests yet.',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Keep your status "Available" to receive new service hire offers nearby.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadInboundJobs(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: jobs.length,
                      itemBuilder: (context, index) {
                        final job = jobs[index];
                        return JobCard(
                          request: job,
                          onAccept: () => _onAcceptJob(job),
                          onChat: () => _onChatWithCustomer(job),
                          onComplete: () {},
                        );
                      },
                    ),
                  );
                }

                return const Center(child: Text('Pull to load inbound jobs.'));
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method returning text label for worker availability status.
  String _getAvailabilityText(WorkerAvailability status) {
    switch (status) {
      case WorkerAvailability.availableNow:
        return 'Available Now';
      case WorkerAvailability.availableToday:
        return 'Available Today';
      case WorkerAvailability.availableThisWeek:
        return 'Available This Week';
      case WorkerAvailability.byAppointment:
        return 'By Appointment';
      case WorkerAvailability.busy:
        return 'Busy';
      case WorkerAvailability.onLeave:
        return 'On Leave';
      case WorkerAvailability.inactive:
        return 'Offline';
    }
  }
}
