import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_first/core/theme/app_theme.dart';
import 'package:local_first/features/admin/presentation/cubits/admin_kyc_cubit.dart';
import 'package:local_first/features/admin/presentation/cubits/admin_kyc_state.dart';
import 'package:local_first/features/admin/presentation/widgets/kyc_review_card.dart';

class AdminKycReviewPage extends StatefulWidget {
  const AdminKycReviewPage({super.key});

  @override
  State<AdminKycReviewPage> createState() => _AdminKycReviewPageState();
}

class _AdminKycReviewPageState extends State<AdminKycReviewPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminKycCubit>().loadPendingKyc();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('KYC Reviews'),
      ),
      body: BlocListener<AdminKycCubit, AdminKycState>(
        listener: (context, state) {
          if (state is AdminKycUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AdminKycError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        child: BlocBuilder<AdminKycCubit, AdminKycState>(
          builder: (context, state) {
            if (state is AdminKycLoading || state is AdminKycUpdating) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AdminKycError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(spacing.edgeMargin),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                      SizedBox(height: spacing.space16),
                      Text(state.message, textAlign: TextAlign.center),
                      SizedBox(height: spacing.space16),
                      ElevatedButton(
                        onPressed: () => context.read<AdminKycCubit>().loadPendingKyc(),
                        child: const Text('RETRY'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is AdminKycLoaded && state.pendingUsers.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => context.read<AdminKycCubit>().loadPendingKyc(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 64,
                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          ),
                          SizedBox(height: spacing.space16),
                          Text(
                            'No Pending KYC Requests',
                            style: theme.textTheme.titleMedium,
                          ),
                          SizedBox(height: spacing.space8),
                          Text(
                            'All users are fully reviewed.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            final listToDisplay = state is AdminKycLoaded ? state.pendingUsers : [];

            return RefreshIndicator(
              onRefresh: () => context.read<AdminKycCubit>().loadPendingKyc(),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: spacing.space8),
                itemCount: listToDisplay.length,
                itemBuilder: (context, index) {
                  final user = listToDisplay[index];
                  return KycReviewCard(
                    user: user,
                    onApprove: (uid, remarks) {
                      context.read<AdminKycCubit>().approveKyc(uid, remarks);
                    },
                    onReject: (uid, remarks) {
                      context.read<AdminKycCubit>().rejectKyc(uid, remarks);
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
