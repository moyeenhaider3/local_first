import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:local_first/core/theme/design_tokens.dart';

/// PROFILE feature - Presentation Layer: Trust Score Gauge Widget
/// Visual gauge component rendering a radial trust score (0-100), tier indicator badge,
/// and civic trust breakdown metrics for Local First users.
class TrustScoreGaugeWidget extends StatelessWidget {
  /// The user's trust score value out of 100.
  final int score;

  /// Optional diameter size of the circular radial gauge arc.
  final double size;

  /// Creates a [TrustScoreGaugeWidget] instance.
  const TrustScoreGaugeWidget({
    super.key,
    required this.score,
    this.size = 180.0,
  });

  /// Computes the community trust tier label based on [score].
  String get _tierTitle {
    if (score >= 85) return 'Super Host & Trusted Citizen';
    if (score >= 70) return 'Verified Neighbor';
    if (score >= 50) return 'Active Community Member';
    return 'New Neighbor';
  }

  /// Computes badge color based on [score].
  Color get _tierColor {
    if (score >= 85) return const Color(0xFF0D9488); // Teal
    if (score >= 70) return const Color(0xFF16A34A); // Green
    if (score >= 50) return const Color(0xFFD97706); // Amber
    return const Color(0xFF64748B); // Slate
  }

  @override
  Widget build(BuildContext context) {
    final clampedScore = score.clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(DesignTokens.kSpace24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(size, size),
                  painter: _GaugePainter(
                    score: clampedScore,
                    primaryColor: _tierColor,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$clampedScore',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: _tierColor,
                        fontFamily: DesignTokens.fontFamily,
                      ),
                    ),
                    const Text(
                      'OUT OF 100',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: DesignTokens.colorTextMuted,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.kSpace16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _tierColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _tierColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user, size: 16, color: _tierColor),
                const SizedBox(width: 6),
                Text(
                  _tierTitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _tierColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.kSpace24),
          const Divider(),
          const SizedBox(height: DesignTokens.kSpace12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _TrustMetricChip(
                icon: Icons.badge_outlined,
                label: 'KYC Verified',
                status: 'Active',
                color: Color(0xFF16A34A),
              ),
              _TrustMetricChip(
                icon: Icons.handshake_outlined,
                label: 'Handshakes',
                status: '100% Safe',
                color: Color(0xFF0D9488),
              ),
              _TrustMetricChip(
                icon: Icons.gavel_outlined,
                label: 'Disputes',
                status: '0 Active',
                color: Color(0xFF2563EB),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Helper CustomPainter to render radial trust arc with rounded stroke ends.
class _GaugePainter extends CustomPainter {
  /// Score value 0 to 100.
  final int score;

  /// Main theme accent color for progress arc.
  final Color primaryColor;

  /// Creates a [_GaugePainter] instance.
  _GaugePainter({
    required this.score,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 14.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    const startAngle = math.pi * 0.75;
    const totalAngle = math.pi * 1.5;

    // Background track paint
    final trackPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalAngle,
      false,
      trackPaint,
    );

    // Dynamic progress arc paint
    final progressSweep = (score / 100.0) * totalAngle;
    if (progressSweep > 0) {
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.7),
            primaryColor,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        progressSweep,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.primaryColor != primaryColor;
  }
}

/// Private sub-widget rendering individual trust score metric pill item.
class _TrustMetricChip extends StatelessWidget {
  /// Icon representing the trust metric.
  final IconData icon;

  /// Metric label text.
  final String label;

  /// Metric status value text.
  final String status;

  /// Accent status color.
  final Color color;

  /// Creates a [_TrustMetricChip] instance.
  const _TrustMetricChip({
    required this.icon,
    required this.label,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: DesignTokens.colorTextMain,
          ),
        ),
        Text(
          status,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
