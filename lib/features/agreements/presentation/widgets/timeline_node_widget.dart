import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:local_first/core/theme/design_tokens.dart';
import 'package:local_first/features/agreements/domain/entities/timeline_event.dart';

/// A widget representing a single node step within the vertical agreement timeline tracker.
class TimelineNodeWidget extends StatefulWidget {
  /// The timeline event object containing status, title, subtitle, and action metadata.
  final TimelineEvent event;

  /// Whether this node is the last item in the timeline (omits bottom connector line).
  final bool isLast;

  /// Callback executed when the node's action button is tapped.
  final ValueChanged<TimelineEvent>? onActionTap;

  /// Creates a [TimelineNodeWidget] instance.
  const TimelineNodeWidget({
    super.key,
    required this.event,
    this.isLast = false,
    this.onActionTap,
  });

  @override
  State<TimelineNodeWidget> createState() => _TimelineNodeWidgetState();
}

class _TimelineNodeWidgetState extends State<TimelineNodeWidget>
    with SingleTickerProviderStateMixin {
  /// Animation controller for active node pulsing animation.
  late AnimationController _pulseController;

  /// Scale animation for the pulsing dot.
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseScale = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.event.status == TimelineNodeStatus.active) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(TimelineNodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.event.status == TimelineNodeStatus.active) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.event.status;
    final isCompleted = status == TimelineNodeStatus.completed;
    final isActive = status == TimelineNodeStatus.active;

    final Color nodeColor = isCompleted
        ? DesignTokens.colorSuccess
        : (isActive ? DesignTokens.colorWarning : const Color(0xFF94A3B8));

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: Node Circle & Vertical Connector Line
          SizedBox(
            width: 32.0,
            child: Column(
              children: [
                const SizedBox(height: 4.0),
                // Node Circle Indicator
                _buildCircleIndicator(nodeColor, isCompleted, isActive),
                // Connector Line
                if (!widget.isLast)
                  Expanded(
                    child: Container(
                      width: 2.0,
                      color: isCompleted
                          ? DesignTokens.colorPrimary
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: DesignTokens.kSpace12),
          // Right: Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.kSpace24),
              child: Container(
                padding: const EdgeInsets.all(DesignTokens.kSpace16),
                decoration: BoxDecoration(
                  color: DesignTokens.colorSurface,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: isActive
                        ? DesignTokens.colorWarning
                        : (isCompleted ? DesignTokens.colorPrimary.withValues(alpha: 0.3) : const Color(0xFFE2E8F0)),
                    width: isActive ? 1.5 : 1.0,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: DesignTokens.colorWarning.withValues(alpha: 0.1),
                            blurRadius: 8.0,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.event.title,
                            style: DesignTokens.titleMedium.copyWith(
                              color: isCompleted || isActive
                                  ? DesignTokens.colorTextMain
                                  : DesignTokens.colorTextMuted,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (widget.event.completedAt != null)
                          Text(
                            DateFormat('dd MMM, HH:mm').format(widget.event.completedAt!),
                            style: DesignTokens.bodySmall.copyWith(
                              color: DesignTokens.colorTextMuted,
                              fontSize: 11.0,
                            ),
                          ),
                      ],
                    ),
                    if (widget.event.subtitle != null) ...[
                      const SizedBox(height: DesignTokens.kSpace4),
                      Text(
                        widget.event.subtitle!,
                        style: DesignTokens.bodyMedium.copyWith(
                          color: isActive
                              ? DesignTokens.colorTextMain
                              : DesignTokens.colorTextMuted,
                        ),
                      ),
                    ],
                    if (isActive && widget.event.actionLabel != null) ...[
                      const SizedBox(height: DesignTokens.kSpace16),
                      SizedBox(
                        width: double.infinity,
                        height: 44.0,
                        child: ElevatedButton(
                          onPressed: () {
                            if (widget.onActionTap != null) {
                              widget.onActionTap!(widget.event);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignTokens.colorPrimary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            widget.event.actionLabel!,
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the 20dp node circle with appropriate icon or pulsing animation.
  Widget _buildCircleIndicator(Color color, bool isCompleted, bool isActive) {
    if (isCompleted) {
      return Container(
        width: 22.0,
        height: 22.0,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 14.0,
        ),
      );
    } else if (isActive) {
      return AnimatedBuilder(
        animation: _pulseScale,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseScale.value,
            child: Container(
              width: 22.0,
              height: 22.0,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2.0),
              ),
              child: Center(
                child: Container(
                  width: 10.0,
                  height: 10.0,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else {
      return Container(
        width: 20.0,
        height: 20.0,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2.0),
        ),
      );
    }
  }
}
