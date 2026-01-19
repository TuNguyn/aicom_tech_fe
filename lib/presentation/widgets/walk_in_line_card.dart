import 'package:flutter/material.dart';
import '../../domain/entities/walk_in_ticket.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';

/// Card widget to display a single service line
class WalkInLineCard extends StatelessWidget {
  final String customerName;
  final WalkInServiceLine serviceLine;
  final DateTime createdAt;
  final VoidCallback onTap;

  const WalkInLineCard({
    super.key,
    required this.customerName,
    required this.serviceLine,
    required this.createdAt,
    required this.onTap,
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
        return 'WAITING';
      case WalkInLineStatus.serving:
        return 'IN SERVICE';
      case WalkInLineStatus.done:
        return 'DONE';
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
  Widget build(BuildContext context) {
    final status = serviceLine.status;
    final statusColor = _getStatusColor(status);

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
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
                            width: 4,
                            height: 4,
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
                                size: 12,
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
                                size: 14,
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
                          width: 40,
                          height: 40,
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
                                fontSize: 16,
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
                                    width: 4,
                                    height: 4,
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
      ),
    );
  }
}
