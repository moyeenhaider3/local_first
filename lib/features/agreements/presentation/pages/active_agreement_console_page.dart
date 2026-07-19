import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:local_first/core/di/service_locator.dart';
import 'package:local_first/core/theme/design_tokens.dart';
import 'package:local_first/features/agreements/domain/entities/agreement_entity.dart';
import 'package:local_first/features/agreements/domain/entities/timeline_event.dart';
import 'package:local_first/features/agreements/presentation/cubits/agreement_timeline_cubit.dart';
import 'package:local_first/features/agreements/presentation/cubits/agreement_timeline_state.dart';
import 'package:local_first/features/agreements/presentation/widgets/status_badge_widget.dart';
import 'package:local_first/features/agreements/presentation/widgets/timeline_node_widget.dart';
import 'package:local_first/features/auth/domain/repositories/auth_repository.dart';
import 'package:local_first/features/verification/presentation/widgets/damage_dispute_bottom_sheet.dart';
import 'package:local_first/features/verification/presentation/widgets/payment_code_bottom_sheet.dart';
import 'package:local_first/features/verification/presentation/widgets/pickup_code_bottom_sheet.dart';
import 'package:local_first/features/verification/presentation/widgets/return_code_bottom_sheet.dart';

/// AGR-01 Active Agreement Timeline Console Page.
///
/// Functions as the central transaction hub showing real-time chronological progress
/// of an agreement with dynamic action buttons linking to verification sheets.
class ActiveAgreementConsolePage extends StatelessWidget {
  /// The agreement ID to load and track in real-time.
  final String agreementId;

  /// Creates an [ActiveAgreementConsolePage] instance.
  const ActiveAgreementConsolePage({
    super.key,
    required this.agreementId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.colorBackground,
      appBar: AppBar(
        backgroundColor: DesignTokens.colorSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DesignTokens.colorTextMain),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Rental Agreement Details',
          style: DesignTokens.h2,
        ),
        actions: [
          BlocBuilder<AgreementTimelineCubit, AgreementTimelineState>(
            builder: (context, state) {
              if (state is TimelineUpdated) {
                return Padding(
                  padding: const EdgeInsets.only(right: DesignTokens.kEdgeMargin),
                  child: Center(
                    child: StatusBadgeWidget(status: state.agreement.status),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<AgreementTimelineCubit, AgreementTimelineState>(
        builder: (context, state) {
          if (state is TimelineLoading || state is TimelineInitial) {
            return const Center(
              child: CircularProgressIndicator(color: DesignTokens.colorPrimary),
            );
          }

          if (state is TimelineError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.kEdgeMargin),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: DesignTokens.colorDanger),
                    const SizedBox(height: DesignTokens.kSpace16),
                    Text(
                      'Failed to load agreement console',
                      style: DesignTokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: DesignTokens.kSpace8),
                    Text(
                      state.message,
                      style: DesignTokens.bodyMedium.copyWith(color: DesignTokens.colorTextMuted),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is TimelineUpdated) {
            final agreement = state.agreement;
            final events = state.events;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(DesignTokens.kEdgeMargin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Agreement Summary Card
                        _buildSummaryCard(agreement),
                        const SizedBox(height: DesignTokens.kSpace24),
                        // Timeline Header
                        Text(
                          'TRANSACTION TIMELINE',
                          style: DesignTokens.bodySmall.copyWith(
                            color: DesignTokens.colorTextMuted,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: DesignTokens.kSpace16),
                        // Vertical Timeline Tracker
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index];
                            return TimelineNodeWidget(
                              event: event,
                              isLast: index == events.length - 1,
                              onActionTap: (evt) => _handleActionTap(context, evt, state),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Sticky Bottom WhatsApp Action Button
                _buildWhatsAppButton(context, agreement),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Builds the summary card displaying contract details, rates, and party summaries.
  Widget _buildSummaryCard(AgreementEntity agreement) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.kSpace16),
      decoration: BoxDecoration(
        color: DesignTokens.colorSurface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.handshake_outlined, size: 20, color: DesignTokens.colorPrimary),
              const SizedBox(width: DesignTokens.kSpace8),
              Expanded(
                child: Text(
                  'Renter ID: ${_shortId(agreement.initiatorId)} ↔ Owner ID: ${_shortId(agreement.counterpartyId)}',
                  style: DesignTokens.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.colorTextMain,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.kSpace12),
          Text(
            'Item: ${agreement.listingTitle} | Daily Rate: ₹${agreement.dailyRate.toStringAsFixed(0)}',
            style: DesignTokens.bodyLarge.copyWith(
              color: DesignTokens.colorTextMain,
            ),
          ),
          const SizedBox(height: DesignTokens.kSpace8),
          Text(
            'Duration: ${agreement.durationDays} days | Total: ₹${agreement.totalAmount.toStringAsFixed(2)}',
            style: DesignTokens.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: DesignTokens.colorPrimary,
            ),
          ),
          const SizedBox(height: DesignTokens.kSpace4),
          Text(
            'Security Deposit: ₹${agreement.depositAmount.toStringAsFixed(2)}',
            style: DesignTokens.bodySmall.copyWith(
              color: DesignTokens.colorTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// Formats long ID string for clean UI display.
  String _shortId(String id) {
    if (id.length <= 8) return id;
    return '${id.substring(0, 6)}...';
  }

  /// Sticky WhatsApp chat button at the bottom of the console.
  Widget _buildWhatsAppButton(BuildContext context, AgreementEntity agreement) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        DesignTokens.kEdgeMargin,
        DesignTokens.kSpace12,
        DesignTokens.kEdgeMargin,
        MediaQuery.of(context).padding.bottom + DesignTokens.kSpace16,
      ),
      decoration: BoxDecoration(
        color: DesignTokens.colorSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52.0,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF16A34A), // WhatsApp Green
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onPressed: () async {
            await _launchWhatsAppChat(context, agreement);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.chat, size: 20, color: Colors.white),
              const SizedBox(width: DesignTokens.kSpace8),
              Text(
                'CHAT ON WHATSAPP',
                style: DesignTokens.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Opens WhatsApp web/app link to chat with counterparty.
  Future<void> _launchWhatsAppChat(BuildContext context, AgreementEntity agreement) async {
    final userResult = await sl<AuthRepository>().getUser(agreement.counterpartyId);
    final counterparty = userResult.fold((_) => null, (u) => u);

    final phone = counterparty?.phone;
    if (phone == null || phone.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Counterparty phone number not available for WhatsApp chat.'),
            backgroundColor: DesignTokens.colorWarning,
          ),
        );
      }
      return;
    }

    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final message = 'Hi, I am reaching out regarding Local First agreement #${agreement.id} for "${agreement.listingTitle}".';
    final url = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');

    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch WhatsApp.'),
            backgroundColor: DesignTokens.colorDanger,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching WhatsApp: $e'),
            backgroundColor: DesignTokens.colorDanger,
          ),
        );
      }
    }
  }

  /// Handles action button taps on active timeline nodes to open appropriate VFY sheets or routes.
  void _handleActionTap(BuildContext context, TimelineEvent event, TimelineUpdated state) {
    final route = event.actionRoute;
    if (route == null) return;

    if (route.contains('/home/legal-consent/')) {
      context.push(route);
    } else if (route.contains('/home/vfy/payment/')) {
      final taskId = route.split('/').last;
      PaymentCodeBottomSheet.show(
        context: context,
        taskId: taskId,
        declaredAmount: state.agreement.totalAmount,
        counterpartyName: 'Counterparty',
      );
    } else if (route.contains('/home/vfy/pickup/')) {
      final taskId = route.split('/').last;
      PickupCodeBottomSheet.show(context, taskId);
    } else if (route.contains('/home/vfy/return/')) {
      final taskId = route.split('/').last;
      ReturnCodeBottomSheet.show(
        context,
        taskId: taskId,
        agreementId: state.agreement.id,
      );
    } else if (route.contains('/home/vfy/dispute/')) {
      DamageDisputeBottomSheet.show(
        context,
        agreementId: state.agreement.id,
      );
    } else {
      context.push(route);
    }
  }
}
