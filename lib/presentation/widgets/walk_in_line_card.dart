import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/toast_utils.dart';
import '../../domain/entities/walk_in_ticket.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_strings.dart';
import '../../app_dependencies.dart';

/// Card widget to display a single service line
class WalkInLineCard extends ConsumerStatefulWidget {
  final String customerName;
  final WalkInServiceLine serviceLine;
  final DateTime createdAt;

  const WalkInLineCard({
    super.key,
    required this.customerName,
    required this.serviceLine,
    required this.createdAt,
  });

  @override
  ConsumerState<WalkInLineCard> createState() => _WalkInLineCardState();
}

class _WalkInLineCardState extends ConsumerState<WalkInLineCard> {
  bool _isProcessing = false;

  Color _getStatusColor(WalkInLineStatus status) {
    switch (status) {
      case WalkInLineStatus.waiting:
        return const Color(0xFFFF6B00); // Vibrant orange
      case WalkInLineStatus.serving:
        return const Color(0xFF00A86B); // Vibrant jade green
      case WalkInLineStatus.done:
        return Colors.grey;
      case WalkInLineStatus.canceled:
        return const Color(0xFFE53935); // Red for canceled
    }
  }

  String _getStatusText(WalkInLineStatus status) {
    switch (status) {
      case WalkInLineStatus.waiting:
        return AppStrings.statusWaiting;
      case WalkInLineStatus.serving:
        return AppStrings.statusInService;
      case WalkInLineStatus.done:
        return AppStrings.statusDone;
      case WalkInLineStatus.canceled:
        return 'Cancelled';
    }
  }

  IconData _getStatusIcon(WalkInLineStatus status) {
    switch (status) {
      case WalkInLineStatus.waiting:
        return Icons.schedule;
      case WalkInLineStatus.serving:
        return Icons.spa_outlined;
      case WalkInLineStatus.done:
        return Icons.check_circle_outline;
      case WalkInLineStatus.canceled:
        return Icons.cancel;
    }
  }

  String _getRelativeTime(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.serviceLine.status;
    final statusColor = _getStatusColor(status);

    // Enable swipe for WAITING and SERVING status only (not for DONE or CANCELED)
    final canSwipe = status == WalkInLineStatus.waiting ||
                     status == WalkInLineStatus.serving;

    final cardContent = _buildCardContent(context, status, statusColor);

    if (!canSwipe) {
      return cardContent;
    }

    return Dismissible(
      key: ValueKey(widget.serviceLine.id),
      direction: DismissDirection.endToStart,
      background: _buildSwipeBackground(status),
      // Use dismissThresholds to make swipe easier
      dismissThresholds: const {
        DismissDirection.endToStart: 0.3, // Only need to swipe 30% to trigger
      },
      // Use movementDuration to control snap back speed
      movementDuration: const Duration(milliseconds: 200),
      confirmDismiss: (direction) async {
        // Show processing state immediately
        setState(() {
          _isProcessing = true;
        });

        // Don't wait for API - return immediately for smooth animation
        // Trigger API call in background without waiting
        Future.microtask(() {
          if (context.mounted) {
            _handleSwipeAction(context, status);
          }
        });
        return false; // Card snaps back immediately - smooth animation
      },
      child: cardContent,
    );
  }

  Widget _buildCardContent(BuildContext context, WalkInLineStatus status, Color statusColor) {
    // Pre-calculate colors to avoid repeated calculations during swipe
    final cardShadowColor = Colors.black.withValues(alpha: 0.08);
    final cardBorderColor = Colors.grey.withValues(alpha: 0.3);
    final decorativeDotColor = statusColor.withValues(alpha: 0.2);
    final headerGradientStart = statusColor.withValues(alpha: 0.15);
    final headerGradientEnd = statusColor.withValues(alpha: 0.08);
    final avatarGradientStart = statusColor.withValues(alpha: 0.25);
    final avatarGradientEnd = statusColor.withValues(alpha: 0.15);
    final avatarBorderColor = statusColor.withValues(alpha: 0.4);
    final statusBadgeShadow = Colors.black.withValues(alpha: 0.05);
    final timeBadgeShadow = statusColor.withValues(alpha: 0.3);

    return RepaintBoundary(
      child: Stack(
        children: [
          Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: cardShadowColor,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: cardBorderColor,
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              // Decorative dots pattern (top right)
              Positioned(
                top: 10,
                right: 10,
                child: Row(
                  children: List.generate(
                      3,
                      (index) => Container(
                            margin: const EdgeInsets.only(left: 3),
                            width: AppDimensions.decorativeDotSize,
                            height: AppDimensions.decorativeDotSize,
                            decoration: BoxDecoration(
                              color: decorativeDotColor,
                              shape: BoxShape.circle,
                            ),
                          )),
                ),
              ),

              Column(
                children: [
                  // Compact header with status and time
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          headerGradientStart,
                          headerGradientEnd,
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: statusBadgeShadow,
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(status),
                                size: AppDimensions.statusIconSize,
                                color: statusColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getStatusText(status),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Created time badge - only show for WAITING status
                        if (status == WalkInLineStatus.waiting)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: timeBadgeShadow,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  color: Colors.white,
                                  size: AppDimensions.statusBadgeIconSize,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getRelativeTime(widget.createdAt),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Content - Avatar and service info
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        Container(
                          width: AppDimensions.avatarSize,
                          height: AppDimensions.avatarSize,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                avatarGradientStart,
                                avatarGradientEnd,
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: avatarBorderColor,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              widget.customerName.isNotEmpty ? widget.customerName[0].toUpperCase() : '?',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: AppDimensions.avatarFontSize,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Name and service
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Customer name
                              Text(
                                widget.customerName,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              // Service line
                              Row(
                                children: [
                                  Container(
                                    width: AppDimensions.decorativeDotSize,
                                    height: AppDimensions.decorativeDotSize,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      widget.serviceLine.lineDescription,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: Colors.grey[800],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                ],
              ),
            ],
          ),
          ),
          // Subtle loading overlay when processing
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Processing',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSwipeBackground(WalkInLineStatus status) {
    // Different color and icon based on status
    final backgroundColor = status == WalkInLineStatus.waiting
        ? const Color(0xFF00A86B) // Green for start
        : const Color(0xFF2196F3); // Blue for complete

    final icon = status == WalkInLineStatus.waiting
        ? Icons.play_arrow // Play icon for start
        : Icons.check_circle; // Check icon for complete

    // Simplified background for better performance
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Icon(
          icon,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  void _handleSwipeAction(
    BuildContext context,
    WalkInLineStatus status,
  ) async {
    final notifier = ref.read(walkInsNotifierProvider.notifier);

    // Call appropriate API based on status
    final bool success;
    final String errorMessage;

    if (status == WalkInLineStatus.waiting) {
      // Start the service
      success = await notifier.startServiceLine(widget.serviceLine.id);
      errorMessage = 'Failed to start service. Please try again.';
    } else {
      // Complete the service (SERVING status)
      success = await notifier.completeServiceLine(widget.serviceLine.id);
      errorMessage = 'Failed to complete service. Please try again.';
    }

    // Clear processing state
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }

    if (!success && context.mounted) {
      // Show error message
      ToastUtils.showError(errorMessage);
    }
    // If success, the refresh API call will update the UI automatically
  }
}
