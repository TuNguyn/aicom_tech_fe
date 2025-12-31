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
// import 'appointment_detail_page.dart'; // Temporarily disabled

class AppointmentsPage extends ConsumerStatefulWidget {
  const AppointmentsPage({super.key});

  @override
  ConsumerState<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends ConsumerState<AppointmentsPage> {
  DateTime _selectedDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();

  // Generate mock appointments for any date
  List<Map<String, dynamic>> _generateMockAppointmentsForDate(DateTime date) {
    // Sunday (weekday % 7 == 0) - No appointments (closed)
    if (date.weekday % 7 == 0) {
      return [];
    }

    // Base appointments that appear on most days
    final baseAppointments = [
      {
        'id': '${date.day}-1',
        'customerName': 'Sarah Johnson',
        'customerPhone': '(555) 123-4567',
        'services': [
          {'name': 'Gel Manicure', 'duration': 60},
        ],
        'scheduledTime': DateTime(date.year, date.month, date.day, 9, 0),
        'status': 'upcoming',
        'notes': 'Customer prefers soft pink color',
      },
      {
        'id': '${date.day}-2',
        'customerName': 'Maria Garcia',
        'customerPhone': '(555) 234-5678',
        'services': [
          {'name': 'Acrylic Full Set', 'duration': 90},
          {'name': 'Nail Art', 'duration': 30},
        ],
        'scheduledTime': DateTime(date.year, date.month, date.day, 10, 30),
        'status': 'in_progress',
        'notes': 'Allergic to certain nail polish - check ingredients first',
      },
      {
        'id': '${date.day}-3',
        'customerName': 'Jennifer Smith',
        'customerPhone': '(555) 345-6789',
        'services': [
          {'name': 'Pedicure Deluxe', 'duration': 75},
        ],
        'scheduledTime': DateTime(date.year, date.month, date.day, 13, 0),
        'status': DateUtils.isSameDay(date, DateTime.now()) ? 'in_progress' : 'upcoming',
        'notes': 'Prefers technician Lisa - very gentle with cuticles',
      },
    ];

    // Different number of appointments for each day
    switch (date.weekday) {
      case DateTime.monday: // Monday - 3 appointments (slow day)
        return baseAppointments;

      case DateTime.tuesday: // Tuesday - 4 appointments
        return [
          ...baseAppointments,
          {
            'id': '${date.day}-4',
            'customerName': 'Emma Wilson',
            'customerPhone': '(555) 456-7890',
            'services': [
              {'name': 'Gel Manicure', 'duration': 60},
              {'name': 'Foot Massage', 'duration': 30},
            ],
            'scheduledTime': DateTime(date.year, date.month, date.day, 14, 30),
            'status': 'upcoming',
            'notes': '',
          },
        ];

      case DateTime.wednesday: // Wednesday - 5 appointments
        return [
          ...baseAppointments,
          {
            'id': '${date.day}-4',
            'customerName': 'Emma Wilson',
            'customerPhone': '(555) 456-7890',
            'services': [
              {'name': 'Gel Manicure', 'duration': 60},
            ],
            'scheduledTime': DateTime(date.year, date.month, date.day, 14, 30),
            'status': 'in_progress',
            'notes': 'Regular customer - knows her favorite color (OPI #15)',
          },
          {
            'id': '${date.day}-5',
            'customerName': 'Olivia Brown',
            'customerPhone': '(555) 678-9012',
            'services': [
              {'name': 'Spa Pedicure', 'duration': 60},
            ],
            'scheduledTime': DateTime(date.year, date.month, date.day, 15, 45),
            'status': 'upcoming',
            'notes': '',
          },
        ];

      case DateTime.thursday: // Thursday - 6 appointments (busy)
        return [
          ...baseAppointments,
          {
            'id': '${date.day}-4',
            'customerName': 'Emma Wilson',
            'customerPhone': '(555) 456-7890',
            'services': [
              {'name': 'Gel Manicure', 'duration': 60},
              {'name': 'Foot Massage', 'duration': 30},
            ],
            'scheduledTime': DateTime(date.year, date.month, date.day, 14, 30),
            'status': 'upcoming',
            'notes': '',
          },
          {
            'id': '${date.day}-5',
            'customerName': 'Isabella Martinez',
            'customerPhone': '(555) 567-8901',
            'services': [
              {'name': 'Acrylic Full Set', 'duration': 90},
              {'name': 'Nail Art', 'duration': 30},
            ],
            'scheduledTime': DateTime(date.year, date.month, date.day, 16, 0),
            'status': 'in_progress',
            'notes': 'VIP customer - full spa package, prefersStation 3',
          },
          {
            'id': '${date.day}-6',
            'customerName': 'Sophia Lee',
            'customerPhone': '(555) 789-0123',
            'services': [
              {'name': 'Manicure', 'duration': 45},
            ],
            'scheduledTime': DateTime(date.year, date.month, date.day, 17, 30),
            'status': 'upcoming',
            'notes': '',
          },
        ];

      case DateTime.friday: // Friday - 7 appointments (very busy)
        return [
          ...baseAppointments,
          {
            'id': '${date.day}-4',
            'customerName': 'Emma Wilson',
            'customerPhone': '(555) 456-7890',
            'services': [
              {'name': 'Gel Manicure', 'duration': 60},
              {'name': 'Foot Massage', 'duration': 30},
            ],
            'scheduledTime': DateTime(date.year, date.month, date.day, 14, 30),
            'status': 'upcoming',
            'notes': '',
          },
          {
            'id': '${date.day}-5',
            'customerName': 'Isabella Martinez',
            'customerPhone': '(555) 567-8901',
            'services': [
              {'name': 'Acrylic Full Set', 'duration': 90},
              {'name': 'Nail Art', 'duration': 30},
              {'name': 'Gel Polish', 'duration': 20},
            ],
            'scheduledTime': DateTime(date.year, date.month, date.day, 16, 0),
            'status': 'in_progress',
            'notes': 'Birthday girl! Wants something extra special and sparkly',
          },
          {
            'id': '${date.day}-6',
            'customerName': 'Sophia Lee',
            'customerPhone': '(555) 789-0123',
            'services': [
              {'name': 'Pedicure', 'duration': 60},
            ],
            'scheduledTime': DateTime(date.year, date.month, date.day, 17, 45),
            'status': 'upcoming',
            'notes': '',
          },
          {
            'id': '${date.day}-7',
            'customerName': 'Ava Taylor',
            'customerPhone': '(555) 890-1234',
            'services': [
              {'name': 'Gel Manicure', 'duration': 60},
            ],
            'scheduledTime': DateTime(date.year, date.month, date.day, 18, 50),
            'status': 'upcoming',
            'notes': 'First time customer - explain all services and prices',
          },
        ];

      case DateTime.saturday: // Saturday - 8 appointments (busiest day)
        return [
          ...baseAppointments,
          {
            'id': '${date.day}-4',
            'customerName': 'Emma Wilson',
            'customerPhone': '(555) 456-7890',
            'services': [
              {'name': 'Gel Manicure', 'duration': 60},
              {'name': 'Foot Massage', 'duration': 30},
            ],
            'scheduledTime': DateTime(date.year, date.month, date.day, 14, 30),
            'status': 'in_progress',
            'notes': 'Has wedding next week - wants color recommendation',
          },
          {
            'id': '${date.day}-5',
            'customerName': 'Isabella Martinez',
            'customerPhone': '(555) 567-8901',
            'services': [
              {'name': 'Acrylic Full Set', 'duration': 90},
              {'name': 'Nail Art', 'duration': 30},
              {'name': 'Gel Polish', 'duration': 20},
              {'name': 'Hand Massage', 'duration': 15},
              {'name': 'Paraffin Treatment', 'duration': 20},
            ],
            'scheduledTime': DateTime(date.year, date.month, date.day, 16, 0),
            'status': 'upcoming',
            'notes': 'VIP customer - full spa package, offer complimentary drink',
          },
          {
            'id': '${date.day}-6',
            'customerName': 'Sophia Lee',
            'customerPhone': '(555) 789-0123',
            'services': [
              {'name': 'Pedicure Deluxe', 'duration': 75},
            ],
            'scheduledTime': DateTime(date.year, date.month, date.day, 17, 30),
            'status': 'upcoming',
            'notes': '',
          },
          {
            'id': '${date.day}-7',
            'customerName': 'Ava Taylor',
            'customerPhone': '(555) 890-1234',
            'services': [
              {'name': 'Gel Manicure', 'duration': 60},
              {'name': 'Nail Art', 'duration': 30},
            ],
            'scheduledTime': DateTime(date.year, date.month, date.day, 18, 50),
            'status': 'upcoming',
            'notes': '',
          },
          {
            'id': '${date.day}-8',
            'customerName': 'Mia Anderson',
            'customerPhone': '(555) 901-2345',
            'services': [
              {'name': 'Manicure', 'duration': 45},
            ],
            'scheduledTime': DateTime(date.year, date.month, date.day, 20, 0),
            'status': 'upcoming',
            'notes': 'Closing time customer - please accommodate if possible',
          },
        ];

      default:
        return baseAppointments;
    }
  }

  List<DateTime> _getWeekDates() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  List<Map<String, dynamic>> _getAppointmentsForSelectedDate() {
    return _generateMockAppointmentsForDate(_selectedDate)
      ..sort((a, b) => (a['scheduledTime'] as DateTime)
          .compareTo(b['scheduledTime'] as DateTime));
  }

  @override
  Widget build(BuildContext context) {
    final appointments = _getAppointmentsForSelectedDate();
    final appointmentCount = appointments.length;

    return Scaffold(
      backgroundColor: AppColors.background,
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
        AppDimensions.spacingXs,
        MediaQuery.of(context).padding.top,
        AppDimensions.spacingXs,
        0,
      ),
      child: Column(
        children: [
          // Top row with icons and user name
          SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                  onPressed: () {
                    context.push(AppRoutes.notifications);
                  },
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Appointments',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                IconButton(
                  icon: const Icon(Icons.exit_to_app, color: Colors.white, size: 24),
                  onPressed: () async {
                    if (!mounted) return;
                    await ref.read(authNotifierProvider.notifier).logout();
                    if (!mounted) return;
                    if (context.mounted) {
                      context.go(AppRoutes.login);
                    }
                  },
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
          final appointmentsCount = _generateMockAppointmentsForDate(date).length;

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
        100, // Extra bottom padding to account for bottom nav bar
      ),
      itemCount: appointments.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.spacingS),
      itemBuilder: (context, index) {
        return AppointmentCard(
          appointment: appointments[index],
          onTap: () {
            // TODO: Temporarily disabled - uncomment when needed
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) => AppointmentDetailPage(
            //       selectedDate: _selectedDate,
            //       appointments: [appointments[index]],
            //     ),
            //   ),
            // );
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
