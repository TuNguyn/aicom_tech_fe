import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app_dependencies.dart';
import '../../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/appointment_card.dart';
import 'appointment_detail_page.dart';

class AppointmentsPage extends ConsumerStatefulWidget {
  const AppointmentsPage({super.key});

  @override
  ConsumerState<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends ConsumerState<AppointmentsPage> {
  DateTime _selectedDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();

  // Mock appointments data - now with support for multiple services
  final List<Map<String, dynamic>> _mockAppointments = [
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
  ];

  List<DateTime> _getWeekDates() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  List<Map<String, dynamic>> _getAppointmentsForSelectedDate() {
    return _mockAppointments.where((apt) {
      final scheduledTime = apt['scheduledTime'] as DateTime;
      return DateUtils.isSameDay(scheduledTime, _selectedDate);
    }).toList()
      ..sort((a, b) => (a['scheduledTime'] as DateTime)
          .compareTo(b['scheduledTime'] as DateTime));
  }

  @override
  Widget build(BuildContext context) {
    final appointments = _getAppointmentsForSelectedDate();
    final appointmentCount = appointments.length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header with date selector
          _buildHeader(appointmentCount),

          // Week Calendar Selector
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

  Widget _buildHeader(int appointmentCount) {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(
        AppDimensions.spacingS,
        MediaQuery.of(context).padding.top + AppDimensions.spacingXs,
        AppDimensions.spacingS,
        AppDimensions.spacingS,
      ),
      child: Column(
        children: [
          // Top row with icons and user name
          SizedBox(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    context.push(AppRoutes.notifications);
                  },
                ),
                Expanded(
                  child: Text(
                    ref.watch(authNotifierProvider).user.fullName,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.exit_to_app, color: Colors.white, size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () async {
                    await ref.read(authNotifierProvider.notifier).logout();
                    if (context.mounted) {
                      context.go(AppRoutes.login);
                    }
                  },
                ),
              ],
            ),
          ),
          // Date and appointment count row
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingM,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('EEEE, MMM d').format(_selectedDate),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$appointmentCount',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCalendar() {
    final weekDates = _getWeekDates();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingS,
        vertical: AppDimensions.spacingXs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: weekDates.map((date) {
          final isSelected = DateUtils.isSameDay(date, _selectedDate);
          final isToday = DateUtils.isSameDay(date, DateTime.now());

          // Count appointments for this date
          final appointmentsCount = _mockAppointments.where((apt) {
            final scheduledTime = apt['scheduledTime'] as DateTime;
            return DateUtils.isSameDay(scheduledTime, date);
          }).length;

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
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingM,
        AppDimensions.spacingS,
        AppDimensions.spacingM,
        AppDimensions.spacingM,
      ),
      itemCount: appointments.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.spacingS),
      itemBuilder: (context, index) {
        return AppointmentCard(
          appointment: appointments[index],
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AppointmentDetailPage(
                  selectedDate: _selectedDate,
                  appointments: [appointments[index]],
                ),
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildEmptyState() {
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Decorative nail-themed illustration
            Container(
              width: 140,
              height: 140,
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.spa_outlined,
                    size: 60,
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  Positioned(
                    right: 35,
                    top: 30,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 30,
                    bottom: 35,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),

            // Message
            Text(
              isToday ? 'No Appointments Today' : 'No Appointments',
              style: AppTextStyles.headlineLarge.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              isToday
                  ? 'Time to relax and prepare for tomorrow!'
                  : 'Enjoy your free time and stay refreshed',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppDimensions.spacingXl),

            // Motivational card
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.08),
                    AppColors.secondary.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pro Tip',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Use this time to organize your station and prepare tools for upcoming appointments',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.grey[700],
                            height: 1.4,
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
      ),
    );
  }
}
