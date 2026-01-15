import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';

class AppointmentCard extends StatefulWidget {
  final Map<String, dynamic> appointment;
  final VoidCallback onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onTap,
  });

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  bool _isExpanded = false;

  // Performance optimization: Cache DateFormat
  static final _timeFormat = DateFormat('h:mm a');

  // Performance optimization: Cache status-based colors
  final Map<String, _StatusColors> _colorCache = {};

  Color _getStatusColor(String status) {
    switch (status) {
      case 'upcoming':
        return AppColors.primary;
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'upcoming':
        return 'Upcoming';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'upcoming':
        return Icons.schedule;
      case 'in_progress':
        return Icons.play_circle_outline;
      case 'completed':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduledTime = widget.appointment['scheduledTime'] as DateTime;
    final services = widget.appointment['services'] as List;
    final status = widget.appointment['status'] as String;
    final statusColor = _getStatusColor(status);
    final hasMultipleServices = services.length > 2;

    // Performance optimization: Pre-calculate all service times in single O(n) pass
    final List<({DateTime start, DateTime end})> serviceTimes = [];
    int cumulativeDuration = 0;
    for (final service in services) {
      final start = scheduledTime.add(Duration(minutes: cumulativeDuration));
      final duration = service['duration'] as int;
      final end = start.add(Duration(minutes: duration));
      serviceTimes.add((start: start, end: end));
      cumulativeDuration += duration;
    }
    final endTime = scheduledTime.add(Duration(minutes: cumulativeDuration));

    // Get displayed services based on expansion state
    final displayedServices = _isExpanded ? services : services.take(2).toList();

    // Performance optimization: Get cached colors for this status
    final colors = _colorCache.putIfAbsent(
      status,
      () => _StatusColors(statusColor),
    );

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {}, // Temporarily disabled navigation
        child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA), // White with slight gray tint
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08), // Neutral shadow
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.3), // Neutral border
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
                children: List.generate(3, (index) => Container(
                  margin: const EdgeInsets.only(left: 3),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.decorativeDot,
                    shape: BoxShape.circle,
                  ),
                )),
              ),
            ),

            Column(
              children: [
                // Header with time and status
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingS),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.headerGradient1,
                        colors.headerGradient2,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Time range with icon
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
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
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  '${_timeFormat.format(scheduledTime)} - ${_timeFormat.format(endTime)}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
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
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingS + 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer info with enhanced design
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  colors.avatarGradient1,
                                  colors.avatarGradient2,
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.avatarBorder,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                widget.appointment['customerName'].toString()[0].toUpperCase(),
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingS),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.appointment['customerName'],
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.phone_rounded,
                                        size: 11,
                                        color: Colors.grey[700],
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        widget.appointment['customerPhone'],
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: Colors.grey[700],
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppDimensions.spacingS),

                      // Services with nail polish theme
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.spacingS),
                        decoration: BoxDecoration(
                          color: colors.serviceContainer,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colors.serviceContainerBorder,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            ...displayedServices.asMap().entries.map((entry) {
                              final index = entry.key;
                              final service = entry.value;

                              // Performance optimization: Use pre-calculated service times
                              final originalIndex = services.indexOf(service);
                              final serviceTime = serviceTimes[originalIndex];
                              final serviceStartTime = serviceTime.start;
                              final serviceEndTime = serviceTime.end;

                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index < displayedServices.length - 1 ? 6 : 0,
                              ),
                              child: Row(
                                children: [
                                  // Nail polish dot - using status color for consistency
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: colors.serviceDotBackground,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: colors.serviceDotBorder,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: statusColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          service['name'],
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${_timeFormat.format(serviceStartTime)} - ${_timeFormat.format(serviceEndTime)}',
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: Colors.grey[600],
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${service['duration']}m',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          // Show more/less button
                          if (hasMultipleServices) ...[
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isExpanded = !_isExpanded;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: statusColor.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                                      size: 14,
                                      color: statusColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _isExpanded
                                        ? 'Show less'
                                        : 'Show ${services.length - 2} more service${services.length - 2 > 1 ? 's' : ''}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                        ),
                      ),

                      // Notes (if any)
                      if (widget.appointment['notes'] != null &&
                          widget.appointment['notes'].toString().isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.spacingS),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacingS,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue[50]!,
                                Colors.blue[50]!.withValues(alpha: 0.5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.blue[200]!,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.sticky_note_2_outlined,
                                size: 14,
                                color: Colors.blue[700],
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.appointment['notes'],
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.blue[900],
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

// Performance optimization: Cache color variations per status
class _StatusColors {
  final Color gradient1;
  final Color gradient2;
  final Color shadow;
  final Color border;
  final Color headerGradient1;
  final Color headerGradient2;
  final Color decorativeDot;
  final Color avatarGradient1;
  final Color avatarGradient2;
  final Color avatarBorder;
  final Color serviceContainer;
  final Color serviceContainerBorder;
  final Color serviceDotBackground;
  final Color serviceDotBorder;

  _StatusColors(Color base)
      : gradient1 = Colors.white,
        gradient2 = base.withValues(alpha: 0.02),
        shadow = base.withValues(alpha: 0.08),
        border = base.withValues(alpha: 0.2),
        headerGradient1 = base.withValues(alpha: 0.12),
        headerGradient2 = base.withValues(alpha: 0.06),
        decorativeDot = base.withValues(alpha: 0.15),
        avatarGradient1 = base.withValues(alpha: 0.2),
        avatarGradient2 = base.withValues(alpha: 0.1),
        avatarBorder = base.withValues(alpha: 0.3),
        serviceContainer = base.withValues(alpha: 0.04),
        serviceContainerBorder = base.withValues(alpha: 0.1),
        serviceDotBackground = base.withValues(alpha: 0.15),
        serviceDotBorder = base.withValues(alpha: 0.4);
}
