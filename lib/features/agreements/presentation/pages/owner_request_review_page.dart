import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:local_first/core/di/service_locator.dart';
import 'package:local_first/core/router/route_names.dart';
import 'package:local_first/core/theme/app_theme.dart';
import 'package:local_first/core/theme/design_tokens.dart';
import 'package:local_first/features/auth/domain/entities/user_entity.dart';
import 'package:local_first/features/auth/domain/repositories/auth_repository.dart';
import 'package:local_first/features/agreements/data/models/request_model.dart';
import 'package:local_first/features/agreements/domain/entities/request_entity.dart';
import 'package:local_first/features/agreements/presentation/cubits/booking_cubit.dart';
import 'package:local_first/features/agreements/presentation/cubits/booking_state.dart';

/// BKG-03 Owner Request Review Page (acceptance/rejection workflow).
class OwnerRequestReviewPage extends StatefulWidget {
  final String requestId;
  final RequestEntity? request;

  const OwnerRequestReviewPage({
    super.key,
    required this.requestId,
    this.request,
  });

  @override
  State<OwnerRequestReviewPage> createState() => _OwnerRequestReviewPageState();
}

class _OwnerRequestReviewPageState extends State<OwnerRequestReviewPage> {
  late Future<Map<String, dynamic>> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadDetails();
  }

  Future<Map<String, dynamic>> _loadDetails() async {
    RequestEntity request;
    if (widget.request != null) {
      request = widget.request!;
    } else {
      final doc = await FirebaseFirestore.instance.collection('requests').doc(widget.requestId).get();
      if (!doc.exists || doc.data() == null) {
        throw Exception('Request not found: ${widget.requestId}');
      }
      request = RequestModel.fromJson(doc.data()!, id: doc.id).toEntity();
    }

    final requesterResult = await sl<AuthRepository>().getUser(request.requesterId);
    final requester = requesterResult.fold(
      (_) => null,
      (user) => user,
    );

    return {
      'request': request,
      'requester': requester,
    };
  }

  /// Displays a confirmation dialog for accepting a booking request.
  void _showAcceptDialog(BuildContext context, String renterName) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Accept Booking Request'),
        content: Text('Accept this booking request from $renterName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 36),
              backgroundColor: DesignTokens.colorPrimary,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<BookingCubit>().acceptBookingRequest(widget.requestId);
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  /// Displays a modal dialog allowing the owner to specify an optional rejection reason.
  void _showRejectDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Reject Booking Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a reason for rejecting this request:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason for rejection (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 36),
              backgroundColor: DesignTokens.colorDanger,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<BookingCubit>().rejectBookingRequest(
                    widget.requestId,
                    reasonController.text.trim().isEmpty ? null : reasonController.text.trim(),
                  );
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final dateFormat = DateFormat('dd MMM yyyy');

    return BlocListener<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        } else if (state is RequestAccepted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request accepted successfully!'),
              backgroundColor: DesignTokens.colorSuccess,
            ),
          );
          // Navigate to WhatsApp handoff placeholder
          context.pushReplacementNamed(
            RouteNames.whatsappRedirect,
            pathParameters: {'requestId': widget.requestId},
          );
        } else if (state is RequestRejected) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request rejected successfully.'),
              backgroundColor: Color(0xFF64748B),
            ),
          );
          // Pop back to requests list
          context.pop();
        }
      },
      child: FutureBuilder<Map<String, dynamic>>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Text('Error loading request: ${snapshot.error}'),
              ),
            );
          }

          final data = snapshot.data!;
          final request = data['request'] as RequestEntity;
          final requester = data['requester'] as UserEntity?;

          final renterName = requester?.displayName ?? 'Renter';
          final bool isKycVerified = requester?.verificationStatus == 'verified';

          final double estimatedTotal = request.estimatedTotal;
          final double estimatedDeposit = request.estimatedDeposit ?? 0.0;
          final int durationDays = request.proposedDurationDays ?? 
              request.proposedEndDate?.difference(request.proposedStartDate).inDays ?? 1;

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: theme.colorScheme.surface,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: theme.colorScheme.secondary),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'Evaluate Booking Request',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: BlocBuilder<BookingCubit, BookingState>(
              builder: (context, state) {
                final bool isLoading = state is BookingLoading;

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(spacing.edgeMargin),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Requester profile card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundImage: requester?.photoUrl != null
                                        ? NetworkImage(requester!.photoUrl!)
                                        : null,
                                    child: requester?.photoUrl == null
                                        ? const Icon(Icons.person, size: 24)
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              renterName,
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            if (isKycVerified)
                                              const Icon(
                                                Icons.verified,
                                                color: DesignTokens.colorSuccess,
                                                size: 18,
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.star, color: Colors.amber, size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Trust Score: 5.0',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: spacing.space24),

                            // Requested terms card
                            Text(
                              'Rental Details',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: spacing.space8),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                children: [
                                  _buildTermRow('Item', request.listingTitle, theme),
                                  const Divider(color: Color(0xFFF1F5F9)),
                                  _buildTermRow(
                                    'Proposed dates',
                                    '${dateFormat.format(request.proposedStartDate)} – ${request.proposedEndDate != null ? dateFormat.format(request.proposedEndDate!) : 'N/A'}',
                                    theme,
                                  ),
                                  const Divider(color: Color(0xFFF1F5F9)),
                                  _buildTermRow('Duration', '$durationDays days', theme),
                                  const Divider(color: Color(0xFFF1F5F9)),
                                  _buildTermRow('Rental charge', '₹${estimatedTotal.toStringAsFixed(2)}', theme),
                                  const Divider(color: Color(0xFFF1F5F9)),
                                  _buildTermRow('Security deposit', '₹${estimatedDeposit.toStringAsFixed(2)}', theme),
                                ],
                              ),
                            ),
                            SizedBox(height: spacing.space24),

                            // Earnings summary card
                            Text(
                              'Earnings Breakdown',
                              style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: spacing.space8),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total earnings',
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                      Text(
                                        '₹${estimatedTotal.toStringAsFixed(2)}',
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: spacing.space8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Platform fee',
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                      Text(
                                        '₹0 (MVP)',
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Divider(color: Color(0xFFE2E8F0)),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Net earnings',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '₹${estimatedTotal.toStringAsFixed(2)}',
                                        style: theme.textTheme.headlineMedium?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: spacing.space32),
                          ],
                        ),
                      ),
                    ),

                    // Double-stacked sticky button panel
                    Container(
                      color: theme.colorScheme.surface,
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.edgeMargin,
                        vertical: spacing.space16,
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                backgroundColor: DesignTokens.colorPrimary,
                              ),
                              onPressed: isLoading ? null : () => _showAcceptDialog(context, renterName),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text('ACCEPT BOOKING REQUEST'),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                side: const BorderSide(color: DesignTokens.colorDanger),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: isLoading ? null : () => _showRejectDialog(context),
                              child: const Text(
                                'REJECT REQUEST',
                                style: TextStyle(
                                  color: DesignTokens.colorDanger,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTermRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
