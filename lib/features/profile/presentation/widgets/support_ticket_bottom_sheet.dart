import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_first/core/theme/design_tokens.dart';
import 'package:local_first/features/profile/domain/entities/support_ticket_entity.dart';
import 'package:local_first/features/profile/presentation/cubits/profile_hub_cubit.dart';
import 'package:local_first/features/profile/presentation/cubits/profile_hub_state.dart';

/// PROFILE & ADMIN feature - Presentation Layer: Support Ticket Bottom Sheet (ADM-01)
/// Modal form bottom sheet for users to create support desk tickets in Local First.
class SupportTicketBottomSheet extends StatefulWidget {
  /// Submitting user ID.
  final String userId;

  /// Submitting user display name.
  final String userName;

  /// Creates a [SupportTicketBottomSheet] instance.
  const SupportTicketBottomSheet({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<SupportTicketBottomSheet> createState() => _SupportTicketBottomSheetState();
}

class _SupportTicketBottomSheetState extends State<SupportTicketBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCategory = 'general';
  String _selectedPriority = 'medium';

  static const List<Map<String, String>> _categories = [
    {'value': 'general', 'label': 'General Support'},
    {'value': 'billing', 'label': 'Payment & Escrow'},
    {'value': 'damage_dispute', 'label': 'Item Damage / Dispute'},
    {'value': 'verification', 'label': 'KYC & Verification'},
    {'value': 'app_bug', 'label': 'App Bug / Feature Request'},
  ];

  static const List<Map<String, String>> _priorities = [
    {'value': 'low', 'label': 'Low Priority'},
    {'value': 'medium', 'label': 'Medium Priority'},
    {'value': 'high', 'label': 'High Priority'},
    {'value': 'urgent', 'label': 'Urgent Issue'},
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Submits support ticket via [ProfileHubCubit].
  void _submitTicket() {
    if (!_formKey.currentState!.validate()) return;

    final ticket = SupportTicketEntity(
      id: '',
      userId: widget.userId,
      userName: widget.userName,
      subject: _subjectController.text.trim(),
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      status: 'open',
      priority: _selectedPriority,
      createdAt: DateTime.now(),
    );

    context.read<ProfileHubCubit>().createSupportTicket(ticket);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        DesignTokens.kSpace16,
        DesignTokens.kSpace24,
        DesignTokens.kSpace16,
        DesignTokens.kSpace24 + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: BlocConsumer<ProfileHubCubit, ProfileHubState>(
        listener: (context, state) {
          if (state is ProfileHubActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: DesignTokens.colorSuccess,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is ProfileHubError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: DesignTokens.colorDanger,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ProfileHubLoading;

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.support_agent, color: DesignTokens.colorPrimary),
                          SizedBox(width: 8),
                          Text(
                            'Local First Support Ticket',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: DesignTokens.colorTextMain,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: DesignTokens.colorTextMuted),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.kSpace16),

                  // Category Dropdown
                  const Text(
                    'Issue Category',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: _categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat['value'],
                        child: Text(cat['label']!),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                  const SizedBox(height: DesignTokens.kSpace16),

                  // Subject Text Input
                  const Text(
                    'Subject / Brief Title',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _subjectController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Damage dispute on drill rental',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter a ticket subject.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: DesignTokens.kSpace16),

                  // Priority Dropdown
                  const Text(
                    'Priority Level',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedPriority,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: _priorities.map((prio) {
                      return DropdownMenuItem(
                        value: prio['value'],
                        child: Text(prio['label']!),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedPriority = val);
                    },
                  ),
                  const SizedBox(height: DesignTokens.kSpace16),

                  // Description Multi-line Input
                  const Text(
                    'Detailed Description',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Describe the issue or assistance needed in detail...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please provide a detailed description.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: DesignTokens.kSpace24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: DesignTokens.kTouchMin,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignTokens.colorPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isLoading ? null : _submitTicket,
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Submit Support Ticket',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
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
