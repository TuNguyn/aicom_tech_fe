import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/appointment_card.dart';

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

  // Mock data for all appointments (should come from API in real app)
  final List<Map<String, dynamic>> _allMockAppointments = [
    {
      'id': '1',
      'customerName': 'Sarah Johnson',
      'customerPhone': '(555) 123-4567',
      'services': [
        {'name': 'Gel Manicure', 'duration': 60},
      ],
      'scheduledTime': DateTime(2025, 12, 26, 10, 0),
      'status': 'upcoming',
      'notes': 'Customer prefers soft pink color',
    },
    {
      'id': '2',
      'customerName': 'Maria Garcia',
      'customerPhone': '(555) 234-5678',
      'services': [
        {'name': 'Acrylic Full Set', 'duration': 90},
        {'name': 'Nail Art', 'duration': 30},
      ],
      'scheduledTime': DateTime(2025, 12, 26, 13, 30),
      'status': 'upcoming',
      'notes': 'Bring extra glitter',
    },
    {
      'id': '3',
      'customerName': 'Jennifer Smith',
      'customerPhone': '(555) 345-6789',
      'services': [
        {'name': 'Pedicure Deluxe', 'duration': 75},
      ],
      'scheduledTime': DateTime(2025, 12, 26, 15, 30),
      'status': 'in_progress',
      'notes': '',
    },
    {
      'id': '4',
      'customerName': 'Emma Wilson',
      'customerPhone': '(555) 456-7890',
      'services': [
        {'name': 'Gel Manicure', 'duration': 60},
        {'name': 'Foot Massage', 'duration': 30},
      ],
      'scheduledTime': DateTime(2025, 12, 27, 9, 0),
      'status': 'upcoming',
      'notes': '',
    },
    {
      'id': '5',
      'customerName': 'Olivia Brown',
      'customerPhone': '(555) 567-8901',
      'services': [
        {'name': 'Manicure & Pedicure', 'duration': 120},
      ],
      'scheduledTime': DateTime(2025, 12, 27, 14, 0),
      'status': 'upcoming',
      'notes': 'Regular customer, knows the drill',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  List<DateTime> _getWeekDates() {
    // Start from the selected date, show 7 days
    final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday % 7));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  List<Map<String, dynamic>> _getAppointmentsForDate(DateTime date) {
    return _allMockAppointments.where((apt) {
      final scheduledTime = apt['scheduledTime'] as DateTime;
      return DateUtils.isSameDay(scheduledTime, date);
    }).toList()
      ..sort((a, b) => (a['scheduledTime'] as DateTime)
          .compareTo(b['scheduledTime'] as DateTime));
  }

  @override
  Widget build(BuildContext context) {
    final appointments = _getAppointmentsForDate(_selectedDate);
    final appointmentCount = appointments.length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Custom Header with gradient
          _buildHeader(),

          // Date info bar
          _buildDateInfoBar(appointmentCount, appointments),

          // Week Calendar Selector (similar to main page)
          _buildWeekCalendar(),

          // Appointments List
          Expanded(
            child: appointments.isEmpty
                ? _buildEmptyState()
                : _buildAppointmentsList(appointments),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingM,
            vertical: AppDimensions.spacingS,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appointment Details',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'View your daily schedule',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateInfoBar(int appointmentCount, List<Map<String, dynamic>> appointments) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.secondary.withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, MMM d').format(_selectedDate),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$appointmentCount appointment${appointmentCount != 1 ? 's' : ''}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (appointmentCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getTotalDuration(appointments),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getTotalDuration(List<Map<String, dynamic>> appointments) {
    final totalMinutes = appointments.fold<int>(0, (sum, apt) {
      final services = apt['services'] as List;
      return sum + services.fold<int>(0, (s, service) => s + (service['duration'] as int));
    });
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  Widget _buildWeekCalendar() {
    final weekDates = _getWeekDates();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingM,
        0,
        AppDimensions.spacingM,
        AppDimensions.spacingS,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: weekDates.map((date) {
          final isSelected = DateUtils.isSameDay(date, _selectedDate);
          final isToday = DateUtils.isSameDay(date, DateTime.now());

          // Count appointments for this date
          final appointmentsCount = _getAppointmentsForDate(date).length;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isToday ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isToday ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('E').format(date).substring(0, 1),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isToday ? AppColors.primary : Colors.grey[600]),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('d').format(date),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (appointmentsCount > 0) ...[
                      const SizedBox(height: 2),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 6),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAppointmentsList(List<Map<String, dynamic>> appointments) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      itemCount: appointments.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.spacingS),
      itemBuilder: (context, index) {
        return AppointmentCard(
          appointment: appointments[index],
          onTap: () {
            // Could navigate to even more detailed view if needed
            _showAppointmentActions(appointments[index]);
          },
        );
      },
    );
  }

  void _showAppointmentActions(Map<String, dynamic> appointment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),

            Text(
              appointment['customerName'],
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),

            _buildActionButton(
              icon: Icons.phone,
              label: 'Call Customer',
              color: Colors.green,
              onTap: () {
                Navigator.pop(context);
                // Implement call functionality
              },
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _buildActionButton(
              icon: Icons.edit,
              label: 'Edit Appointment',
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                // Implement edit functionality
              },
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _buildActionButton(
              icon: Icons.cancel,
              label: 'Cancel Appointment',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                // Implement cancel functionality
              },
            ),
            const SizedBox(height: AppDimensions.spacingM),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingM,
          vertical: AppDimensions.spacingM,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: AppDimensions.spacingM),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.secondary.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.spa_outlined,
                size: 50,
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            Text(
              'No Appointments',
              style: AppTextStyles.headlineLarge.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              'No appointments scheduled for this day',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
