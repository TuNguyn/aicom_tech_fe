import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/appointment_line_model.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';

// Cache for status-based styling to avoid repeated calculations
class _AppointmentCardStyle {
  final Color statusColor;
  final Color timeBadgeColor;
  final List<Color> gradientColors;
  final String statusText;
  final IconData statusIcon;

  // Pre-calculated color variations with alpha
  final Color borderColor;
  final Color shadowColor;
  final Color dotColor;
  final Color avatarGradientStart;
  final Color avatarGradientEnd;
  final Color avatarBorder;
  final Color serviceBackground;
  final Color serviceBorder;
  final Color serviceDotBackground;
  final Color serviceDotBorder;
  final Color serviceDotCenter;
  final Color timeBadgeShadow;

  _AppointmentCardStyle._({
    required this.statusColor,
    required this.timeBadgeColor,
    required this.gradientColors,
    required this.statusText,
    required this.statusIcon,
    required this.borderColor,
    required this.shadowColor,
    required this.dotColor,
    required this.avatarGradientStart,
    required this.avatarGradientEnd,
    required this.avatarBorder,
    required this.serviceBackground,
    required this.serviceBorder,
    required this.serviceDotBackground,
    required this.serviceDotBorder,
    required this.serviceDotCenter,
    required this.timeBadgeShadow,
  });

  // Static cache for styles based on status
  static final Map<String, _AppointmentCardStyle> _cache = {};

  factory _AppointmentCardStyle.fromStatus(String status) {
    final normalizedStatus = status.toUpperCase();

    // Return cached style if available
    if (_cache.containsKey(normalizedStatus)) {
      return _cache[normalizedStatus]!;
    }

    // Determine colors based on status
    final bool isCancelled = normalizedStatus == 'CANCELLED' || normalizedStatus == 'NO_SHOW';

    final Color statusColor = isCancelled
        ? const Color(0xFFEF9A9A)  // Soft coral/pink for cancelled
        : const Color(0xFF6B8CD9); // Blue color for normal

    final Color timeBadgeColor = isCancelled
        ? const Color(0xFFE88B8B)  // Soft coral for cancelled
        : const Color(0xFF5578C7); // Darker blue for confirmed

    final List<Color> gradientColors = isCancelled
        ? const [Color(0xFFFFC1C1), Color(0xFFFFDAE0)] // Soft pink gradient
        : const [Color(0xFF9DB4E8), Color(0xFFB8C9F0)]; // Blue gradient

    String statusText;
    switch (normalizedStatus) {
      case 'SCHEDULED':
        statusText = 'Scheduled';
        break;
      case 'IN_PROGRESS':
        statusText = 'In Progress';
        break;
      case 'CHECKED_IN':
        statusText = 'Checked In';
        break;
      case 'COMPLETED':
        statusText = 'Completed';
        break;
      case 'CANCELLED':
        statusText = 'CANCELLED';
        break;
      case 'NO_SHOW':
        statusText = 'No Show';
        break;
      default:
        statusText = status;
    }

    IconData statusIcon;
    switch (normalizedStatus) {
      case 'SCHEDULED':
        statusIcon = Icons.schedule;
        break;
      case 'CONFIRMED':
        statusIcon = Icons.check_circle;
        break;
      case 'IN_PROGRESS':
      case 'CHECKED_IN':
        statusIcon = Icons.play_circle_outline;
        break;
      case 'COMPLETED':
        statusIcon = Icons.check_circle_outline;
        break;
      case 'CANCELLED':
      case 'NO_SHOW':
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusIcon = Icons.event_available;
    }

    // Pre-calculate all color variations
    final style = _AppointmentCardStyle._(
      statusColor: statusColor,
      timeBadgeColor: timeBadgeColor,
      gradientColors: gradientColors,
      statusText: statusText,
      statusIcon: statusIcon,
      borderColor: statusColor.withValues(alpha: 0.4),
      shadowColor: Colors.black.withValues(alpha: 0.08),
      dotColor: statusColor.withValues(alpha: 0.3),
      avatarGradientStart: statusColor.withValues(alpha: 0.3),
      avatarGradientEnd: statusColor.withValues(alpha: 0.15),
      avatarBorder: statusColor.withValues(alpha: 0.5),
      serviceBackground: statusColor.withValues(alpha: 0.06),
      serviceBorder: statusColor.withValues(alpha: 0.15),
      serviceDotBackground: statusColor.withValues(alpha: 0.2),
      serviceDotBorder: statusColor.withValues(alpha: 0.5),
      serviceDotCenter: statusColor,
      timeBadgeShadow: timeBadgeColor.withValues(alpha: 0.3),
    );

    // Cache the style
    _cache[normalizedStatus] = style;
    return style;
  }
}

class AppointmentCardApi extends StatelessWidget {
  final AppointmentLineModel appointment;

  const AppointmentCardApi({super.key, required this.appointment});

  // Static time formatter to avoid repeated instantiation
  static final _timeFormat = DateFormat('h:mm a');

  @override
  Widget build(BuildContext context) {
    // Get cached style for this status
    final style = _AppointmentCardStyle.fromStatus(appointment.appointment.status);

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: style.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: style.borderColor, width: 1.5),
        ),
        child: Stack(
          children: [
            // Decorative dots pattern (top right) - using pre-built const widgets
            Positioned(
              top: 10,
              right: 7,
              child: _DecorativeDotsRow(color: style.dotColor),
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
                      colors: style.gradientColors,
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
                            color: style.timeBadgeColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: style.timeBadgeShadow,
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
                                  '${_timeFormat.format(appointment.beginTime)} - ${_timeFormat.format(appointment.endTime)}',
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
                          border: Border.all(color: style.statusColor, width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0D000000), // 0.05 alpha
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              style.statusIcon,
                              size: 12,
                              color: style.statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              style.statusText,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: style.statusColor,
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
                                  style.avatarGradientStart,
                                  style.avatarGradientEnd,
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: style.avatarBorder,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                appointment.appointment.customer.firstName[0]
                                    .toUpperCase(),
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: style.statusColor,
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
                          color: style.serviceBackground,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: style.serviceBorder,
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
                                color: style.serviceDotBackground,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: style.serviceDotBorder,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: style.serviceDotCenter,
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
                        _NoteSection(note: appointment.appointment.note!),
                      ],
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
}

// Widget for decorative dots row with dynamic color
class _DecorativeDotsRow extends StatelessWidget {
  final Color color;

  const _DecorativeDotsRow({required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _dot(color),
        const SizedBox(width: 3),
        _dot(color),
        const SizedBox(width: 3),
        _dot(color),
      ],
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

// Separate widget for note section with static gradient colors
class _NoteSection extends StatelessWidget {
  final String note;

  const _NoteSection({required this.note});

  // Static gradient and colors to avoid recalculation
  static const _noteGradientStart = Color(0xFFE3F2FD); // blue[50]
  static const _noteGradientEnd = Color(0x80E3F2FD);   // blue[50] with 0.5 alpha
  static const _noteBorderColor = Color(0xFF90CAF9);   // blue[200]
  static const _noteIconColor = Color(0xFF1976D2);     // blue[700]
  static const _noteTextColor = Color(0xFF0D47A1);     // blue[900]

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingS,
        vertical: 6,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_noteGradientStart, _noteGradientEnd],
        ),
        borderRadius: BorderRadius.all(Radius.circular(6)),
        border: Border.fromBorderSide(
          BorderSide(color: _noteBorderColor, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.sticky_note_2_outlined,
            size: 14,
            color: _noteIconColor,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              note,
              style: AppTextStyles.bodySmall.copyWith(
                color: _noteTextColor,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
