import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/walk_in_ticket.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_strings.dart';
import '../../app_dependencies.dart';

/// Card widget to display a single service line
class WalkInLineCard extends ConsumerWidget {
  final String customerName;
  final WalkInServiceLine serviceLine;
  final DateTime createdAt;

  const WalkInLineCard({
    super.key,
    required this.customerName,
    required this.serviceLine,
    required this.createdAt,
  });

  Color _getStatusColor(WalkInLineStatus status) {
    switch (status) {
      case WalkInLineStatus.waiting:
        return const Color(0xFFFF6B00); // Vibrant orange
      case WalkInLineStatus.serving:
        return const Color(0xFF00A86B); // Vibrant jade green
      case WalkInLineStatus.done:
        return Colors.grey;
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
  Widget build(BuildContext context, WidgetRef ref) {
    final status = serviceLine.status;
    final statusColor = _getStatusColor(status);

    // Enable swipe for WAITING and SERVING status
    final canSwipe = status == WalkInLineStatus.waiting ||
                     status == WalkInLineStatus.serving;

    if (!canSwipe) {
      return _buildCardContent(context, status, statusColor);
    }

    return Dismissible(
      key: ValueKey(serviceLine.id),
      direction: DismissDirection.endToStart,
      background: _buildSwipeBackground(status),
      confirmDismiss: (direction) async {
        return await _handleSwipeDismiss(context, ref, status);
      },
      child: _buildCardContent(context, status, statusColor),
    );
  }

  Widget _buildCardContent(BuildContext context, WalkInLineStatus status, Color statusColor) {
    return RepaintBoundary(
      child: Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.3),
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
                              color: statusColor.withValues(alpha: 0.2),
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
                          statusColor.withValues(alpha: 0.15),
                          statusColor.withValues(alpha: 0.08),
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
                                color: Colors.black.withValues(alpha: 0.05),
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
                        // Created time badge
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
                                color: statusColor.withValues(alpha: 0.3),
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
                                _getRelativeTime(createdAt),
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
                                statusColor.withValues(alpha: 0.25),
                                statusColor.withValues(alpha: 0.15),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              customerName.isNotEmpty ? customerName[0].toUpperCase() : '?',
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
                                customerName,
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
                                      serviceLine.lineDescription,
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
                              const SizedBox(height: 4),
                              // Employee name
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 12,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    serviceLine.employeeName,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.grey[600],
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
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

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: backgroundColor,
          child: Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }

  Future<bool> _handleSwipeDismiss(
    BuildContext context,
    WidgetRef ref,
    WalkInLineStatus status,
  ) async {
    final notifier = ref.read(walkInsNotifierProvider.notifier);

    // Call appropriate API based on status
    final bool success;
    final String errorMessage;

    if (status == WalkInLineStatus.waiting) {
      // Start the service
      success = await notifier.startServiceLine(serviceLine.id);
      errorMessage = 'Failed to start service. Please try again.';
    } else {
      // Complete the service (SERVING status)
      success = await notifier.completeServiceLine(serviceLine.id);
      errorMessage = 'Failed to complete service. Please try again.';
    }

    if (!success && context.mounted) {
      // Show error and keep card in place
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return false; // Don't dismiss card
    }

    // Success - allow dismissal (card will refresh with new status)
    return true;
  }
}
