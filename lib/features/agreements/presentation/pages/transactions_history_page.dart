import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_first/core/theme/design_tokens.dart';
import 'package:local_first/features/agreements/domain/entities/agreement_entity.dart';
import 'package:local_first/features/agreements/domain/entities/request_entity.dart';
import 'package:local_first/features/agreements/presentation/cubits/transactions_cubit.dart';
import 'package:local_first/features/agreements/presentation/cubits/transactions_state.dart';
import 'package:local_first/features/agreements/presentation/widgets/booking_request_card.dart';
import 'package:local_first/features/agreements/presentation/widgets/transaction_card.dart';

/// AGR-02 Transaction History Page displayed in the Activity tab of the shell.
///
/// Shows 3 categorized transaction tabs (REQUESTS, ACTIVE TRANSACTIONS, & COMPLETED HISTORY)
/// with pull-to-refresh, empty state illustrations, and navigation to request/agreement consoles.
class TransactionsHistoryPage extends StatelessWidget {
  /// Creates a [TransactionsHistoryPage] instance.
  const TransactionsHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: DesignTokens.colorBackground,
        appBar: AppBar(
          backgroundColor: DesignTokens.colorSurface,
          elevation: 0,
          title: Text(
            'Your Activity',
            style: DesignTokens.h1.copyWith(fontSize: 24.0),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(48.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                isScrollable: true,
                indicatorColor: DesignTokens.colorPrimary,
                indicatorWeight: 3.0,
                labelColor: DesignTokens.colorPrimary,
                unselectedLabelColor: DesignTokens.colorTextMuted,
                labelStyle: DesignTokens.labelBold,
                tabs: [
                  Tab(text: 'REQUESTS'),
                  Tab(text: 'ACTIVE TRANSACTIONS'),
                  Tab(text: 'COMPLETED HISTORY'),
                ],
              ),
            ),
          ),
        ),
        body: BlocBuilder<TransactionsCubit, TransactionsState>(
          builder: (context, state) {
            if (state is TransactionsLoading || state is TransactionsInitial) {
              return const Center(
                child: CircularProgressIndicator(color: DesignTokens.colorPrimary),
              );
            }

            if (state is TransactionsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(DesignTokens.kEdgeMargin),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: DesignTokens.colorDanger),
                      const SizedBox(height: DesignTokens.kSpace16),
                      Text(
                        'Failed to load transactions',
                        style: DesignTokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: DesignTokens.kSpace8),
                      Text(
                        state.message,
                        style: DesignTokens.bodyMedium.copyWith(color: DesignTokens.colorTextMuted),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: DesignTokens.kSpace24),
                      ElevatedButton(
                        onPressed: () => context.read<TransactionsCubit>().loadAgreements(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesignTokens.colorPrimary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('RETRY'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is TransactionsLoaded) {
              return TabBarView(
                children: [
                  // Booking Requests Tab
                  _buildRequestsTabList(
                    context: context,
                    requests: state.requests,
                  ),
                  // Active Transactions Tab
                  _buildTabList(
                    context: context,
                    agreements: state.activeAgreements,
                    emptyMessage: 'No active transactions',
                    emptyIcon: Icons.receipt_long,
                  ),
                  // Completed History Tab
                  _buildTabList(
                    context: context,
                    agreements: state.completedAgreements,
                    emptyMessage: 'No completed transactions',
                    emptyIcon: Icons.history,
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  /// Builds a scrollable list of booking requests or an empty state view.
  Widget _buildRequestsTabList({
    required BuildContext context,
    required List<RequestEntity> requests,
  }) {
    return RefreshIndicator(
      color: DesignTokens.colorPrimary,
      onRefresh: () async {
        await context.read<TransactionsCubit>().loadAgreements();
      },
      child: requests.isEmpty
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.inbox_outlined,
                        size: 48.0,
                        color: DesignTokens.colorTextMuted,
                      ),
                      const SizedBox(height: DesignTokens.kSpace16),
                      Text(
                        'No booking requests',
                        style: DesignTokens.bodyLarge.copyWith(
                          color: DesignTokens.colorTextMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: DesignTokens.kSpace8),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return BookingRequestCard(request: request);
              },
            ),
    );
  }

  /// Builds a scrollable pull-to-refresh list or empty state view for a transaction tab.
  Widget _buildTabList({
    required BuildContext context,
    required List<AgreementEntity> agreements,
    required String emptyMessage,
    required IconData emptyIcon,
  }) {
    return RefreshIndicator(
      color: DesignTokens.colorPrimary,
      onRefresh: () async {
        await context.read<TransactionsCubit>().loadAgreements();
      },
      child: agreements.isEmpty
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        emptyIcon,
                        size: 48.0,
                        color: DesignTokens.colorTextMuted,
                      ),
                      const SizedBox(height: DesignTokens.kSpace16),
                      Text(
                        emptyMessage,
                        style: DesignTokens.bodyLarge.copyWith(
                          color: DesignTokens.colorTextMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: DesignTokens.kSpace8),
              itemCount: agreements.length,
              itemBuilder: (context, index) {
                final agreement = agreements[index];
                return TransactionCard(agreement: agreement);
              },
            ),
    );
  }
}
