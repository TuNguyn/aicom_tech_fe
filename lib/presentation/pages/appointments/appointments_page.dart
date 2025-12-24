import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'appointment_detail_page.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  DateTime _selectedDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();

  // Time slots from 9:00 AM to 8:00 PM in 15-minute intervals
  final List<String> _timeSlots = [
    '09:00am', '09:15am', '09:30am', '09:45am',
    '10:00am', '10:15am', '10:30am', '10:45am',
    '11:00am', '11:15am', '11:30am', '11:45am',
    '12:00pm', '12:15pm', '12:30pm', '12:45pm',
    '01:00pm', '01:15pm', '01:30pm', '01:45pm',
    '02:00pm', '02:15pm', '02:30pm', '02:45pm',
    '03:00pm', '03:15pm', '03:30pm', '03:45pm',
    '04:00pm', '04:15pm', '04:30pm', '04:45pm',
    '05:00pm', '05:15pm', '05:30pm', '05:45pm',
    '06:00pm', '06:15pm', '06:30pm', '06:45pm',
    '07:00pm', '07:15pm', '07:30pm', '07:45pm',
  ];

  // Mock appointments data with grid positions
  final List<Map<String, dynamic>> _appointments = [
    {
      'id': '1',
      'customerName': 'Sarah Johnson',
      'service': 'Gel Manicure',
      'dayIndex': 3, // Wednesday
      'timeSlotIndex': 12, // 12:00pm
      'duration': 4, // 4 slots = 60 minutes
      'color': Colors.pink,
    },
    {
      'id': '2',
      'customerName': 'Maria Garcia',
      'service': 'Acrylic Full Set',
      'dayIndex': 3, // Wednesday
      'timeSlotIndex': 17, // 01:15pm
      'duration': 6, // 6 slots = 90 minutes
      'color': Colors.red,
    },
  ];

  List<DateTime> _getWeekDates() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Week Calendar Header
          _buildWeekCalendar(),

          // Calendar Grid
          Expanded(
            child: _buildCalendarGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCalendar() {
    final weekDates = _getWeekDates();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Empty space for time column
          const SizedBox(width: 80),
          // Days
          Expanded(
            child: Row(
              children: weekDates.map((date) {
                final isSelected = DateUtils.isSameDay(date, _selectedDate);
                final isToday = DateUtils.isSameDay(date, DateTime.now());

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : (isToday ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('d').format(date),
                            style: AppTextStyles.titleLarge.copyWith(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final weekDates = _getWeekDates();

    return SingleChildScrollView(
      controller: _scrollController,
      child: Container(
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time column
            _buildTimeColumn(),
            // Grid for each day
            Expanded(
              child: Stack(
                children: [
                  // Grid lines
                  _buildGridLines(weekDates.length),
                  // Appointments
                  ..._buildAppointmentBlocks(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeColumn() {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Column(
        children: _timeSlots.map((time) {
          return Container(
            height: 60,
            alignment: Alignment.topRight,
            padding: const EdgeInsets.only(right: 8, top: 4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Text(
              time,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey[700],
                fontSize: 11,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGridLines(int dayCount) {
    return Column(
      children: _timeSlots.map((time) {
        return Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
          ),
          child: Row(
            children: List.generate(
              dayCount,
              (index) => Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: Colors.grey[200]!,
                        width: index < dayCount - 1 ? 1 : 0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildAppointmentBlocks() {
    final dayWidth = (MediaQuery.of(context).size.width - 80) / 7;

    return _appointments.map((apt) {
      final left = apt['dayIndex'] * dayWidth;
      final top = apt['timeSlotIndex'] * 60.0;
      final height = apt['duration'] * 60.0;

      return Positioned(
        left: left,
        top: top,
        width: dayWidth - 2,
        height: height,
        child: GestureDetector(
          onTap: () {
            _showAppointmentDetails(apt);
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: apt['color'],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  apt['customerName'],
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (height > 40)
                  Text(
                    apt['service'],
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 9,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  void _showAppointmentDetails(Map<String, dynamic> apt) {
    // Get the date from the clicked appointment
    final appointmentDate = _getWeekDates()[apt['dayIndex']];

    // Get all appointments for that day
    final dayAppointments = _appointments.where((a) =>
      a['dayIndex'] == apt['dayIndex']
    ).toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AppointmentDetailPage(
          selectedDate: appointmentDate,
          appointments: dayAppointments,
        ),
      ),
    );
  }
}
