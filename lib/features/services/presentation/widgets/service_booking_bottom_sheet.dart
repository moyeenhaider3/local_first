import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:local_first/features/agreements/presentation/widgets/whatsapp_redirect_bottom_sheet.dart';
import 'package:local_first/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:local_first/features/services/domain/entities/service_profile_entity.dart';
import 'package:local_first/features/services/domain/entities/service_request_entity.dart';
import 'package:local_first/features/services/presentation/cubits/services_cubit.dart';
import 'package:local_first/features/services/presentation/cubits/services_state.dart';

/// SERVICES feature - Presentation Layer: Service Booking Bottom Sheet (HIRE-02)
/// Interactive modal bottom sheet enabling customers to submit service requests to workers.
class ServiceBookingBottomSheet extends StatefulWidget {
  /// Target service worker profile entity.
  final ServiceProfileEntity workerProfile;

  /// Creates a [ServiceBookingBottomSheet] widget.
  const ServiceBookingBottomSheet({
    super.key,
    required this.workerProfile,
  });

  @override
  State<ServiceBookingBottomSheet> createState() => _ServiceBookingBottomSheetState();
}

class _ServiceBookingBottomSheetState extends State<ServiceBookingBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _jobDescriptionController = TextEditingController();

  /// Selected date for service execution. Defaults to tomorrow.
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  @override
  void dispose() {
    _jobDescriptionController.dispose();
    super.dispose();
  }

  /// Displays date picker dialog allowing customer to choose scheduled date.
  Future<void> _pickScheduledDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Handles submission of the service request.
  void _submitRequest(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to submit a service request.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final currentUserId = authState.uid;
    final currentUserName = authState.userEntity?.displayName ?? 'Customer';

    final request = ServiceRequestEntity(
      id: '',
      workerId: widget.workerProfile.userId,
      workerName: widget.workerProfile.displayName,
      customerId: currentUserId,
      customerName: currentUserName,
      jobDescription: _jobDescriptionController.text.trim(),
      scheduledDate: _selectedDate,
      estimatedRate: widget.workerProfile.startingRate,
      rateUnit: widget.workerProfile.rateUnit,
      status: ServiceRequestStatus.pending,
      createdAt: DateTime.now(),
    );

    context.read<ServicesCubit>().sendServiceRequest(request);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: BlocConsumer<ServicesCubit, ServicesState>(
        listener: (context, state) {
          if (state is ServiceRequestSent) {
            // Dismiss bottom sheet and open WhatsApp redirect modal
            Navigator.of(context).pop();
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (modalCtx) => WhatsAppRedirectBottomSheet(requestId: state.requestId),
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
          final isLoading = state is ServicesLoading;

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Drag handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Modal Header Title
                  Text(
                    'Book Service: ${widget.workerProfile.displayName}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Category: ${widget.workerProfile.primarySkillName}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Job Description Input (min height 120dp requirement)
                  Text(
                    'Job Description',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120, // 120dp height constraint per design system
                    child: TextFormField(
                      controller: _jobDescriptionController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText: 'Describe the work required, address, or specific instructions...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please provide a job description.';
                        }
                        if (value.trim().length < 10) {
                          return 'Job description must be at least 10 characters.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Date Picker Button (min height 48dp requirement)
                  Text(
                    'Scheduled Date',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 48, // 48dp height requirement per design system
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: isLoading ? null : () => _pickScheduledDate(context),
                      icon: const Icon(Icons.calendar_month, size: 20),
                      label: Text(
                        formattedDate,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Rate Display Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Estimated Starting Rate',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '₹${widget.workerProfile.startingRate.toStringAsFixed(0)} / ${widget.workerProfile.rateUnit}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Request Button (48dp height)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _submitRequest(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              'CONFIRM SERVICE REQUEST',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
