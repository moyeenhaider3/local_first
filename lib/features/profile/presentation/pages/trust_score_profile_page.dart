import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_first/core/theme/design_tokens.dart';
import 'package:local_first/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:local_first/features/profile/domain/entities/review_entity.dart';
import 'package:local_first/features/profile/presentation/cubits/profile_hub_cubit.dart';
import 'package:local_first/features/profile/presentation/cubits/profile_hub_state.dart';
import 'package:local_first/features/profile/presentation/widgets/trust_score_gauge_widget.dart';

/// PROFILE feature - Presentation Layer: Trust Score Profile Page (PROF-02)
/// Renders radial trust gauge score, peer review feed list, and recalculate score action in Local First.
class TrustScoreProfilePage extends StatefulWidget {
  /// Creates a [TrustScoreProfilePage] instance.
  const TrustScoreProfilePage({super.key});

  @override
  State<TrustScoreProfilePage> createState() => _TrustScoreProfilePageState();
}

class _TrustScoreProfilePageState extends State<TrustScoreProfilePage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      context.read<ProfileHubCubit>().loadProfileData(authState.uid);
    }
  }

  /// Triggers a fresh server calculation of trust metrics.
  void _recalculateScore(BuildContext context, String userId) {
    context.read<ProfileHubCubit>().recalculateTrustScore(userId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recalculating community trust score...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final userId = authState is AuthSuccess ? authState.uid : '';

    return Scaffold(
      backgroundColor: DesignTokens.colorBgDark,
      appBar: AppBar(
        title: const Text(
          'Trust Profile & Reviews',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: DesignTokens.colorTextMain,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DesignTokens.colorTextMain),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<ProfileHubCubit, ProfileHubState>(
        listener: (context, state) {
          if (state is ProfileHubError) {
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
          if (state is ProfileHubLoading) {
            return const Center(
              child: CircularProgressIndicator(color: DesignTokens.colorPrimary),
            );
          }

          final score = state is ProfileHubLoaded ? state.trustScore : 85;
          final reviews = state is ProfileHubLoaded ? state.reviews : <ReviewEntity>[];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(DesignTokens.kSpace16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Radial Trust Score Gauge Widget
                TrustScoreGaugeWidget(score: score),
                const SizedBox(height: DesignTokens.kSpace16),

                // Recalculate Button Action
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignTokens.colorPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.refresh, size: 20),
                    label: const Text(
                      'Recalculate Trust Metrics',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () => _recalculateScore(context, userId),
                  ),
                ),
                const SizedBox(height: DesignTokens.kSpace24),

                // Reviews Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Peer Community Reviews (${reviews.length})',
                      style: DesignTokens.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Icon(Icons.rate_review_outlined, color: DesignTokens.colorTextMuted),
                  ],
                ),
                const SizedBox(height: DesignTokens.kSpace12),

                // Peer Reviews Feed
                if (reviews.isEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(DesignTokens.kSpace32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: const [
                        Icon(
                          Icons.stars_outlined,
                          size: 48,
                          color: DesignTokens.colorTextMuted,
                        ),
                        SizedBox(height: DesignTokens.kSpace12),
                        Text(
                          'No Peer Reviews Yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: DesignTokens.colorTextMain,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Complete rentals or hire services in Local First to earn verified reviews and build your community trust badge!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: DesignTokens.colorTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviews.length,
                    separatorBuilder: (context, index) => const SizedBox(height: DesignTokens.kSpace12),
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return _ReviewFeedCard(review: review);
                    },
                  ),
                ],
                const SizedBox(height: DesignTokens.kSpace32),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Private sub-widget rendering individual review feed card.
class _ReviewFeedCard extends StatelessWidget {
  /// Review item entity.
  final ReviewEntity review;

  /// Creates a [_ReviewFeedCard] instance.
  const _ReviewFeedCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.kSpace16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: DesignTokens.colorPrimary.withValues(alpha: 0.15),
                child: Text(
                  review.reviewerName.isNotEmpty ? review.reviewerName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: DesignTokens.colorPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: DesignTokens.colorTextMain,
                      ),
                    ),
                    Text(
                      'Type: ${review.reviewType.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: DesignTokens.colorTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 16, color: Color(0xFFD97706)),
                    const SizedBox(width: 4),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.kSpace12),
            Text(
              review.comment,
              style: const TextStyle(
                fontSize: 14,
                color: DesignTokens.colorTextMain,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
