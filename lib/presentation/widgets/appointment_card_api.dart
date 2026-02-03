import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/appointment_line.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';

class _AppointmentCardStyle {
  final Color statusColor;
  final Color timeBadgeColor;
  final List<Color> gradientColors;
  final String statusText;
  final IconData statusIcon;

  // Pre-calculated color variations for performance
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

  static final Map<String, _AppointmentCardStyle> _cache = {};

  factory _AppointmentCardStyle.fromStatus(String status) {
    final normalizedStatus = status.toUpperCase();
    if (_cache.containsKey(normalizedStatus)) {
      return _cache[normalizedStatus]!;
    }

    Color baseColor;
    Color darkerColor;
    List<Color> gradient;
    IconData icon;
    String text;

    switch (normalizedStatus) {
      case 'SCHEDULED':
        baseColor = const Color(0xFF4A90E2); // Classic Blue
        darkerColor = const Color(0xFF357ABD);
        gradient = [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)];
        icon = Icons.schedule;
        text = 'SCHEDULED';
        break;
      case 'CONFIRMED':
        baseColor = const Color(0xFF5C7BD9); // Xanh dương dịu (Cornflower Blue)
        darkerColor = const Color(0xFF4A68C2);
        gradient = [
          const Color(0xFFE8EAF6),
          const Color(0xFFC5CAE9),
        ]; // Xanh nhạt gradient
        icon = Icons.check_circle;
        text = 'CONFIRMED';
        break;
      case 'CHECKED_IN':
        baseColor = const Color(0xFF9C27B0); // Purple indicating presence
        darkerColor = const Color(0xFF7B1FA2);
        gradient = [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)];
        icon = Icons.how_to_reg;
        text = 'CHECKED_IN';
        break;
      case 'IN_PROGRESS':
        baseColor = const Color(0xFFEF6C00); // Orange/Amber for active state
        darkerColor = const Color(0xFFE65100);
        gradient = [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)];
        icon = Icons.play_circle_filled;
        text = 'IN_PROGRESS';
        break;
      case 'COMPLETED':
        baseColor = const Color(0xFF009688); // Teal for successful completion
        darkerColor = const Color(0xFF00796B);
        gradient = [const Color(0xFFE0F2F1), const Color(0xFFB2DFDB)];
        icon = Icons.task_alt;
        text = 'COMPLETED';
        break;
      case 'CANCELLED':
      case 'NO_SHOW':
        baseColor = const Color(0xFFE53935); // Red for negative states
        darkerColor = const Color(0xFFC62828);
        gradient = [const Color(0xFFFFEBEE), const Color(0xFFFFCDD2)];
        icon = Icons.cancel;
        text = normalizedStatus == 'NO_SHOW' ? 'NO_SHOW' : 'CANCELLED ';
        break;
      default:
        // Fallback for unknown states
        baseColor = const Color(0xFF607D8B); // Blue Grey
        darkerColor = const Color(0xFF455A64);
        gradient = [const Color(0xFFECEFF1), const Color(0xFFCFD8DC)];
        icon = Icons.help_outline;
        text = status;
    }

    final style = _AppointmentCardStyle._(
      statusColor: baseColor,
      timeBadgeColor: darkerColor,
      gradientColors: gradient,
      statusText: text,
      statusIcon: icon,
      borderColor: baseColor.withValues(alpha: 0.4),
      shadowColor: Colors.black.withValues(alpha: 0.08),
      dotColor: baseColor.withValues(alpha: 0.3),
      avatarGradientStart: baseColor.withValues(alpha: 0.3),
      avatarGradientEnd: baseColor.withValues(alpha: 0.15),
      avatarBorder: baseColor.withValues(alpha: 0.5),
      serviceBackground: baseColor.withValues(alpha: 0.06),
      serviceBorder: baseColor.withValues(alpha: 0.15),
      serviceDotBackground: baseColor.withValues(alpha: 0.2),
      serviceDotBorder: baseColor.withValues(alpha: 0.5),
      serviceDotCenter: baseColor,
      timeBadgeShadow: darkerColor.withValues(alpha: 0.3),
    );

    _cache[normalizedStatus] = style;
    return style;
  }
}

class AppointmentCardApi extends StatelessWidget {
  final AppointmentLine appointment;

  const AppointmentCardApi({super.key, required this.appointment});

  static final _timeFormat = DateFormat('h:mm a');

  @override
  Widget build(BuildContext context) {
    final style = _AppointmentCardStyle.fromStatus(appointment.status);

    // Lấy ký tự đầu của tên khách hàng một cách an toàn
    final customerInitial = appointment.customerName.isNotEmpty
        ? appointment.customerName[0].toUpperCase()
        : '?';

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
            Positioned(
              top: 10,
              right: 7,
              child: _DecorativeDotsRow(color: style.dotColor),
            ),
            Column(
              children: [
                // Header with Time and Status
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: style.statusColor,
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0D000000),
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

                // Body with Customer, Service, and Notes
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingS + 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                customerInitial,
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
                                  appointment.customerName,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                                        appointment.customerPhone,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: Colors.grey[700],
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
                                appointment.serviceName,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
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
                      if (appointment.note != null &&
                          appointment.note!.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.spacingS),
                        _NoteSection(note: appointment.note!),
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
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _NoteSection extends StatelessWidget {
  final String note;
  const _NoteSection({required this.note});

  static const _noteGradientStart = Color(0xFFE3F2FD);
  static const _noteGradientEnd = Color(0x80E3F2FD);
  static const _noteBorderColor = Color(0xFF90CAF9);
  static const _noteIconColor = Color(0xFF1976D2);
  static const _noteTextColor = Color(0xFF0D47A1);

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
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
