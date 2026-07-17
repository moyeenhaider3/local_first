import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:local_first/core/di/service_locator.dart';
import 'package:local_first/core/theme/app_theme.dart';
import 'package:local_first/core/theme/design_tokens.dart';
import 'package:local_first/features/auth/domain/repositories/auth_repository.dart';
import 'package:local_first/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:local_first/features/auth/domain/entities/user_entity.dart';
import 'package:local_first/features/agreements/data/models/request_model.dart';
import 'package:local_first/features/agreements/domain/entities/request_entity.dart';

/// BKG-04 WhatsApp redirect screen designed to look like a bottom sheet.
class WhatsAppRedirectBottomSheet extends StatefulWidget {
  final String requestId;

  const WhatsAppRedirectBottomSheet({
    super.key,
    required this.requestId,
  });

  @override
  State<WhatsAppRedirectBottomSheet> createState() => _WhatsAppRedirectBottomSheetState();
}

class _WhatsAppRedirectBottomSheetState extends State<WhatsAppRedirectBottomSheet> {
  late Future<Map<String, dynamic>> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _loadDetails();
  }

  Future<Map<String, dynamic>> _loadDetails() async {
    // Fetch current user details before async gap to avoid BuildContext warning
    final authState = context.read<AuthCubit>().state;
    final currentUserId = (authState is AuthSuccess) ? authState.uid : '';

    // 1. Fetch request document
    final doc = await FirebaseFirestore.instance.collection('requests').doc(widget.requestId).get();
    if (!doc.exists || doc.data() == null) {
      throw Exception('Request not found: ${widget.requestId}');
    }
    final request = RequestModel.fromJson(doc.data()!, id: doc.id).toEntity();

    // 3. Determine counterparty ID
    final String counterpartyId = (currentUserId == request.requesterId)
        ? request.receiverId
        : request.requesterId;

    // 4. Fetch profiles
    final counterpartyResult = await sl<AuthRepository>().getUser(counterpartyId);
    final counterparty = counterpartyResult.fold((_) => null, (user) => user);

    final requesterResult = await sl<AuthRepository>().getUser(request.requesterId);
    final requester = requesterResult.fold((_) => null, (user) => user);

    final receiverResult = await sl<AuthRepository>().getUser(request.receiverId);
    final receiver = receiverResult.fold((_) => null, (user) => user);

    return {
      'request': request,
      'counterparty': counterparty,
      'requester': requester,
      'receiver': receiver,
      'currentUserId': currentUserId,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.secondary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'WhatsApp Coordination',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading request details',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;
          final request = data['request'] as RequestEntity;
          final counterparty = data['counterparty'] as UserEntity?;
          final requester = data['requester'] as UserEntity?;
          final receiver = data['receiver'] as UserEntity?;
          final currentUserId = data['currentUserId'] as String;

          final counterpartyName = counterparty?.displayName ?? 'User';
          final phone = (currentUserId == request.requesterId)
              ? receiver?.phone
              : requester?.phone;

          final isRental = request.requestType == RequestType.rental;
          final dateFormat = DateFormat('dd MMM yyyy');

          final String templateText;
          if (isRental) {
            final ownerName = receiver?.displayName ?? 'Owner';
            final itemName = request.listingTitle;
            final startDate = dateFormat.format(request.proposedStartDate);
            final endDate = request.proposedEndDate != null ? dateFormat.format(request.proposedEndDate!) : '';
            templateText = 'Hi $ownerName, I am interested in renting $itemName from $startDate to $endDate. My request reference is ${request.id}.';
          } else {
            final workerName = receiver?.displayName ?? 'Worker';
            final skillName = request.listingTitle;
            final preferredDate = dateFormat.format(request.proposedStartDate);
            final jobDescription = request.message != null && request.message!.isNotEmpty ? request.message! : 'service';
            templateText = 'Hi $workerName, I need a $skillName for $jobDescription on $preferredDate. My request reference is ${request.id}.';
          }

          return Column(
            children: [
              // Drag handle decoration
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: spacing.edgeMargin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Redirecting to WhatsApp',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Coordinate handover logistics and payments directly with $counterpartyName over WhatsApp.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF64748B),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'PRE-WRITTEN MESSAGE',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          templateText,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Icon(Icons.security, size: 16, color: theme.colorScheme.secondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Sensitive KYC details or private contract codes are not included in this message for privacy.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Sticky button at bottom
              Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.edgeMargin,
                  8,
                  spacing.edgeMargin,
                  MediaQuery.of(context).padding.bottom + 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E), // WhatsApp green
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      if (phone == null || phone.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Counterparty phone number is not available.'),
                            backgroundColor: DesignTokens.colorWarning,
                          ),
                        );
                        return;
                      }

                      final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
                      final encodedText = Uri.encodeComponent(templateText);
                      final url = Uri.parse('https://wa.me/$cleanPhone?text=$encodedText');

                      try {
                        final launched = await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                        if (!launched) {
                          throw Exception('Could not launch WhatsApp');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Could not open WhatsApp: ${e.toString()}'),
                              backgroundColor: theme.colorScheme.error,
                            ),
                          );
                        }
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'OPEN WHATSAPP CHAT',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
