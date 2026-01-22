import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/appointment_line_model.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';

class AppointmentCardApi extends StatelessWidget {
  final AppointmentLineModel appointment;

  const AppointmentCardApi({super.key, required this.appointment});

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        return 'Scheduled';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'CHECKED_IN':
        return 'Checked In';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'CANCELLED';
      case 'NO_SHOW':
        return 'No Show';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CANCELLED':
      case 'NO_SHOW':
        return const Color(0xFFEF9A9A); // Soft coral/pink for cancelled
      default:
        return const Color(0xFF6B8CD9); // Blue color for normal
    }
  }

  List<Color> _getGradientColors(String status) {
    switch (status.toUpperCase()) {
      case 'CANCELLED':
      case 'NO_SHOW':
        return [const Color(0xFFFFC1C1), const Color(0xFFFFDAE0)]; // Soft pink gradient
      default:
        return [const Color(0xFF9DB4E8), const Color(0xFFB8C9F0)]; // Blue gradient
    }
  }

  Color _getTimeBadgeColor(String status) {
    switch (status.toUpperCase()) {
      case 'CANCELLED':
      case 'NO_SHOW':
        return const Color(0xFFE88B8B); // Soft coral for cancelled
      default:
        return const Color(0xFF5578C7); // Darker blue for confirmed
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        return Icons.schedule;
      case 'CONFIRMED':
        return Icons.check_circle;
      case 'IN_PROGRESS':
      case 'CHECKED_IN':
        return Icons.play_circle_outline;
      case 'COMPLETED':
        return Icons.check_circle_outline;
      case 'CANCELLED':
      case 'NO_SHOW':
        return Icons.cancel_outlined;
      default:
        return Icons.event_available;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');
    final statusColor = _getStatusColor(appointment.appointment.status);
    final timeBadgeColor = _getTimeBadgeColor(appointment.appointment.status);

    return Container(
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
        border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 1.5),
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
                    color: statusColor.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
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
                    colors: _getGradientColors(appointment.appointment.status),
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
                          color: timeBadgeColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: timeBadgeColor.withValues(alpha: 0.3),
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
                                '${timeFormat.format(appointment.beginTime)} - ${timeFormat.format(appointment.endTime)}',
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
                            _getStatusIcon(appointment.appointment.status),
                            size: 12,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getStatusText(appointment.appointment.status),
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
                    // Customer info
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
                                statusColor.withValues(alpha: 0.3),
                                statusColor.withValues(alpha: 0.15),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              appointment.appointment.customer.firstName[0]
                                  .toUpperCase(),
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
                                appointment.appointment.customer.fullName,
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
                                      appointment.appointment.customer.phone,
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

                    // Service
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.spacingS),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Service dot
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.5),
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
                            child: Text(
                              appointment.service.name,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
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
                              '${appointment.durationMinute}m',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Notes (if any)
                    if (appointment.appointment.note != null &&
                        appointment.appointment.note!.isNotEmpty) ...[
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
                                appointment.appointment.note!,
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
    );
  }
}
