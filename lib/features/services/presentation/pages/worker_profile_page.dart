import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:local_first/core/router/route_names.dart';
import 'package:local_first/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:local_first/features/services/domain/entities/review_entity.dart';
import 'package:local_first/features/services/domain/entities/service_profile_entity.dart';
import 'package:local_first/features/services/domain/entities/worker_availability.dart';
import 'package:local_first/features/services/presentation/cubits/services_cubit.dart';
import 'package:local_first/features/services/presentation/cubits/services_state.dart';
import 'package:local_first/features/services/presentation/widgets/service_booking_bottom_sheet.dart';

/// SERVICES feature - Presentation Layer: Worker Profile Page (HIRE-01)
/// Displays service worker public details, skills, experience, verified status, reviews, and booking request button.
class WorkerProfilePage extends StatefulWidget {
  /// Unique user ID of the service worker to display.
  final String workerId;

  /// Creates a [WorkerProfilePage] widget.
  const WorkerProfilePage({
    super.key,
    required this.workerId,
  });

  @override
  State<WorkerProfilePage> createState() => _WorkerProfilePageState();
}

class _WorkerProfilePageState extends State<WorkerProfilePage> {
  @override
  void initState() {
    super.initState();
    // Dispatch initial fetch for worker profile details and reviews
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServicesCubit>().fetchWorkerProfile(widget.workerId);
    });
  }

  /// Handles tap on [REQUEST SERVICE BOOKING] with KYC gate enforcement.
  void _handleBookingRequest(BuildContext context, ServiceProfileEntity profile) {
    final authState = context.read<AuthCubit>().state;

    // Check if the current user is authenticated and KYC verified
    bool isKycVerified = false;
    if (authState is AuthSuccess) {
      final user = authState.userEntity;
      isKycVerified = user?.verificationStatus == 'verified' || authState.hasKyc;
    }

    if (!isKycVerified) {
      // Prompt user about KYC requirement before proceeding to service booking
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('KYC verification is required before requesting service bookings in Local First.'),
          backgroundColor: Colors.orange,
        ),
      );
      context.pushNamed(RouteNames.kycUpload);
      return;
    }

    // Verified user can proceed to open the booking bottom sheet modal
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => ServiceBookingBottomSheet(workerProfile: profile),
    );
  }

  /// Helper method returning status label string for availability status.
  String _getAvailabilityLabel(WorkerAvailability status) {
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

  /// Helper method returning status indicator color.
  Color _getAvailabilityColor(WorkerAvailability status) {
    switch (status) {
      case WorkerAvailability.availableNow:
      case WorkerAvailability.availableToday:
      case WorkerAvailability.availableThisWeek:
        return Colors.green;
      case WorkerAvailability.busy:
      case WorkerAvailability.byAppointment:
        return Colors.orange;
      case WorkerAvailability.onLeave:
      case WorkerAvailability.inactive:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Profile'),
        centerTitle: true,
      ),
      body: BlocBuilder<ServicesCubit, ServicesState>(
        builder: (context, state) {
          if (state is ServicesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ServicesError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.message,
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ServicesCubit>().fetchWorkerProfile(widget.workerId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is WorkerProfileLoaded) {
            final profile = state.profile;
            final reviews = state.reviews;

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card with Avatar (72dp), Name, Rate, KYC badge & Availability
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  // Avatar 72dp
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(36),
                                    child: CircleAvatar(
                                      radius: 36, // 72dp diameter
                                      backgroundColor: theme.colorScheme.primaryContainer,
                                      backgroundImage: profile.photoUrl != null && profile.photoUrl!.isNotEmpty
                                          ? NetworkImage(profile.photoUrl!)
                                          : null,
                                      child: profile.photoUrl == null || profile.photoUrl!.isEmpty
                                          ? Icon(Icons.person, size: 40, color: theme.colorScheme.primary)
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                profile.displayName,
                                                style: theme.textTheme.titleLarge?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (profile.isKycVerified) ...[
                                              const SizedBox(width: 4),
                                              const Icon(
                                                Icons.verified,
                                                color: Colors.blue,
                                                size: 20,
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          profile.primarySkillName,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        // Availability badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getAvailabilityColor(profile.availabilityStatus).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: _getAvailabilityColor(profile.availabilityStatus).withValues(alpha: 0.5),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.circle,
                                                size: 8,
                                                color: _getAvailabilityColor(profile.availabilityStatus),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _getAvailabilityLabel(profile.availabilityStatus),
                                                style: theme.textTheme.labelSmall?.copyWith(
                                                  color: _getAvailabilityColor(profile.availabilityStatus),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24, thickness: 1),

                              // Starting Rate & Rating summary row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        'Starting Rate',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '₹${profile.startingRate.toStringAsFixed(0)} / ${profile.rateUnit}',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(height: 30, width: 1, color: const Color(0xFFCBD5E1)),
                                  Column(
                                    children: [
                                      Text(
                                        'Trust & Rating',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 18),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${profile.trustScore.toStringAsFixed(1)} (${profile.totalReviews})',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Skills Section with 32dp skill chips
                      Text(
                        'Skills & Specialties',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profile.skills.map((skill) {
                          return Container(
                            height: 32, // 32dp chip height requirement
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              skill,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // About / Experience Section
                      if (profile.experience != null && profile.experience!.isNotEmpty) ...[
                        Text(
                          'About Worker',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          profile.experience!,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Client Reviews Section
                      Text(
                        'Client Reviews (${reviews.length})',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (reviews.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'No reviews submitted yet for this worker.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: reviews.length,
                          separatorBuilder: (context, idx) => const Divider(height: 16),
                          itemBuilder: (context, index) {
                            final review = reviews[index];
                            return _buildReviewTile(theme, review);
                          },
                        ),
                    ],
                  ),
                ),

                // Sticky Bottom Action Bar with [REQUEST SERVICE BOOKING]
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => _handleBookingRequest(context, profile),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'REQUEST SERVICE BOOKING',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Helper method rendering individual client review tile.
  Widget _buildReviewTile(ThemeData theme, ReviewEntity review) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(review.createdAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              review.reviewerName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  review.rating.toStringAsFixed(1),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          review.comment,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          formattedDate,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}
