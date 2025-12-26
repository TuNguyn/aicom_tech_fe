import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

class AppointmentDetailPage extends StatefulWidget {
  final DateTime selectedDate;
  final List<Map<String, dynamic>> appointments;

  const AppointmentDetailPage({
    super.key,
    required this.selectedDate,
    required this.appointments,
  });

  @override
  State<AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  late DateTime _selectedDate;
  late List<Map<String, dynamic>> _dayAppointments;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _dayAppointments = _convertAppointmentsToTimeline(widget.appointments);
  }

  List<Map<String, dynamic>> _convertAppointmentsToTimeline(List<Map<String, dynamic>> appointments) {
    // Convert appointments to timeline format with start/end times
    return appointments.map((apt) {
      final scheduledTime = apt['scheduledTime'] as DateTime;
      final services = apt['services'] as List;
      final totalDuration = services.fold<int>(
        0,
        (sum, service) => sum + (service['duration'] as int),
      );
      final endTime = scheduledTime.add(Duration(minutes: totalDuration));

      String formatTime(DateTime time) {
        return DateFormat('h:mm a').format(time);
      }

      // Get status color
      final status = apt['status'] as String;
      Color statusColor;
      switch (status) {
        case 'upcoming':
          statusColor = const Color(0xFF6B7FD7);
          break;
        case 'in_progress':
          statusColor = Colors.orange;
          break;
        case 'completed':
          statusColor = Colors.green;
          break;
        case 'cancelled':
          statusColor = Colors.red;
          break;
        default:
          statusColor = Colors.grey;
      }

      return {
        'id': apt['id'],
        'customerName': apt['customerName'],
        'customerPhone': apt['customerPhone'],
        'services': services,
        'startTime': formatTime(scheduledTime),
        'endTime': formatTime(endTime),
        'duration': totalDuration,
        'color': statusColor,
        'status': status,
        'notes': apt['notes'] ?? '',
      };
    }).toList();
  }

  List<DateTime> _getWeekDates() {
    // Start from the appointment date, show 7 days forward
    return List.generate(7, (index) => _selectedDate.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = _getWeekDates();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Detail Appointment',
          style: AppTextStyles.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.spacingL),
              child: Text(
                DateFormat('EEEE, MMMM d yyyy').format(_selectedDate),
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Week Calendar
            _buildWeekCalendar(weekDates),

            const SizedBox(height: AppDimensions.spacingL),

            // Appointment Timeline
            _buildAppointmentTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekCalendar(List<DateTime> weekDates) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingM),
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDates.length,
        itemBuilder: (context, index) {
          final date = weekDates[index];
          final isSelected = DateUtils.isSameDay(date, _selectedDate);
          final isToday = DateUtils.isSameDay(date, DateTime.now());

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isToday ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent),
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected
                          ? Colors.white
                          : (isToday ? AppColors.primary : Colors.grey[700]),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d').format(date),
                    style: AppTextStyles.displayMedium.copyWith(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentTimeline() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        children: _dayAppointments.map((apt) {
          return _buildTimelineItem(apt);
        }).toList(),
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> apt) {
    final isLast = apt == _dayAppointments.last;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline
        Column(
          children: [
            // Start time
            Text(
              apt['startTime'],
              style: AppTextStyles.titleLarge.copyWith(
                color: apt['color'],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Start dot
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: apt['color'],
                shape: BoxShape.circle,
              ),
            ),
            // Timeline line
            if (!isLast || true) // Always show line to end time
              Container(
                width: 2,
                height: 100,
                color: apt['color'],
              ),
            // End dot
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: apt['color'],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 8),
            // End time
            Text(
              apt['endTime'],
              style: AppTextStyles.titleLarge.copyWith(
                color: apt['color'],
                fontWeight: FontWeight.bold,
              ),
            ),
            // Extra spacing between appointments
            if (!isLast) const SizedBox(height: 30),
          ],
        ),

        const SizedBox(width: AppDimensions.spacingL),

        // Appointment Details Card
        Expanded(
          child: Container(
            margin: EdgeInsets.only(top: 30, bottom: isLast ? 0 : 30),
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            decoration: BoxDecoration(
              color: apt['color'].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              border: Border.all(
                color: apt['color'].withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  'Customer:',
                  apt['customerName'],
                ),
                const SizedBox(height: AppDimensions.spacingS),
                _buildDetailRow(
                  'Phone:',
                  apt['customerPhone'],
                ),
                const SizedBox(height: AppDimensions.spacingM),
                Text(
                  'Services:',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                ...(apt['services'] as List).map((service) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${service['name']} (${service['duration']} min)',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                )).toList(),
                const SizedBox(height: AppDimensions.spacingM),
                _buildDetailRow(
                  'Total time:',
                  '${apt['duration']} minutes',
                ),
                if (apt['notes'] != null && apt['notes'].toString().isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingM),
                  Text(
                    'Notes:',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  Text(
                    apt['notes'],
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.black87,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
