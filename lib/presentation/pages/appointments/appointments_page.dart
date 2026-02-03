import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app_dependencies.dart';
import '../../../core/utils/toast_utils.dart';
import '../../../routes/app_routes.dart';
import '../../../domain/entities/appointment_line.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/appointment_card_api.dart';
import '../../widgets/logout_dialog.dart';

class AppointmentsPage extends ConsumerStatefulWidget {
  const AppointmentsPage({super.key});

  @override
  ConsumerState<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends ConsumerState<AppointmentsPage>
    with AutomaticKeepAliveClientMixin {
  DateTime _selectedDate = DateTime.now();
  bool _isInitialLoad = true;

  @override
  bool get wantKeepAlive => true;

  static final _dayFormat = DateFormat('E');
  static final _dateFormat = DateFormat('d');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointmentsForWeek(DateTime.now());
    });
  }

  void _loadAppointmentsForWeek(DateTime date) {
    final weekday = date.weekday;
    final startDate = date.subtract(Duration(days: weekday - 1));
    final endDate = startDate.add(const Duration(days: 6));

    ref
        .read(appointmentsNotifierProvider.notifier)
        .loadAppointmentsForDateRange(startDate, endDate);
  }

  List<DateTime> _getWeekDates() {
    final weekday = _selectedDate.weekday;
    final monday = _selectedDate.subtract(Duration(days: weekday - 1));

    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final appointmentsState = ref.watch(appointmentsNotifierProvider);
    final appointments = appointmentsState.getAppointmentsForDate(
      _selectedDate,
    );

    final isLoading = appointmentsState.loadingStatus.isLoading;
    final appointmentCount = appointments.length;

    ref.listen<String>(authNotifierProvider.select((state) => state.user.id), (
      previous,
      next,
    ) {
      if (previous != null &&
          previous.isNotEmpty &&
          previous != next &&
          next.isNotEmpty) {
        _isInitialLoad = true;
        _selectedDate = DateTime.now();
        _loadAppointmentsForWeek(DateTime.now());
      }
    });

    ref.listen<AsyncValue<void>>(
      appointmentsNotifierProvider.select((state) => state.loadingStatus),
      (previous, next) {
        next.whenOrNull(
          data: (_) {
            if (_isInitialLoad) {
              setState(() {
                _isInitialLoad = false;
              });
            }
          },
          error: (error, stack) {
            if (_isInitialLoad) {
              setState(() {
                _isInitialLoad = false;
              });
            }
            ToastUtils.showError(error.toString());
          },
        );
      },
    );

    final shouldShowLoading =
        isLoading && _isInitialLoad && appointments.isEmpty;

    return Container(
      decoration: BoxDecoration(gradient: AppColors.mainBackgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            _buildHeader(appointmentCount),
            _buildWeekCalendar(),
            Expanded(
              child: shouldShowLoading
                  ? _buildLoadingState()
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref
                            .read(appointmentsNotifierProvider.notifier)
                            .refreshAppointments();
                      },
                      child: appointments.isEmpty
                          ? _buildEmptyState()
                          : _buildAppointmentsList(appointments),
                    ),
            ),
          ],
        ),
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
        4,
      ),
      child: SizedBox(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 24,
              ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$appointmentCount',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white, size: 24),
              onPressed: () {
                LogoutDialog.show(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekCalendar() {
    final weekDates = _getWeekDates();

    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: weekDates.map((date) => _buildDateItem(date)).toList(),
      ),
    );
  }

  Widget _buildDateItem(DateTime date) {
    final isSelected =
        date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;

    final isToday =
        date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
        ref.read(appointmentsNotifierProvider.notifier).selectDate(date);
      },
      child: Container(
        width: 48,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : isToday
              ? Colors.white.withValues(alpha: 0.1)
              : null,
          borderRadius: BorderRadius.circular(12),
          border: isToday && !isSelected
              ? Border.all(color: Colors.white, width: 1)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _dayFormat.format(date),
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? AppColors.primary : Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _dateFormat.format(date),
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.primary : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height:
              MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              56 -
              88 -
              kBottomNavigationBarHeight -
              40,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No appointments',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You have no appointments for this date',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentsList(List<AppointmentLine> appointments) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppointmentCardApi(appointment: appointment),
        );
      },
    );
  }
}
