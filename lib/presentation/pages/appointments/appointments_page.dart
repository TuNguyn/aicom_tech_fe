import 'package:aicom_tech_fe/core/utils/timezone_utils.dart';
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

  // Trạng thái load lần đầu tiên vào app
  bool _isInitialLoad = true;
  // [MỚI] Trạng thái khi người dùng bấm đổi ngày
  bool _isSwitchingDate = false;

  @override
  bool get wantKeepAlive => true;

  static final _dayFormat = DateFormat('E');
  static final _dateFormat = DateFormat('d');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointmentsForSelectedDate();
    });
  }

  // (DateTime, DateTime) _getDateRange() {
  //   final start = DateTime(
  //     _selectedDate.year,
  //     _selectedDate.month,
  //     _selectedDate.day,
  //     0,
  //     0,
  //     0,
  //   );
  //   final end = DateTime(
  //     _selectedDate.year,
  //     _selectedDate.month,
  //     _selectedDate.day,
  //     23,
  //     59,
  //     59,
  //   );
  //   return (start, end);
  // }

  void _loadAppointmentsForSelectedDate() {
    final (hybridStart, hybridEnd) = TimezoneUtils.getHybridDateRange(
      _selectedDate,
    );

    ref
        .read(appointmentsNotifierProvider.notifier)
        .fetchAppointments(
          startDate: hybridStart, // Sẽ là ngày 4 (UTC)
          endDate: hybridEnd, // Sẽ là ngày 5 hoặc 6 (Local)
          isRefresh: true,
        );
  }

  void _loadMoreAppointments() {
    final (hybridStart, hybridEnd) = TimezoneUtils.getHybridDateRange(
      _selectedDate,
    );

    ref
        .read(appointmentsNotifierProvider.notifier)
        .fetchAppointments(
          startDate: hybridStart,
          endDate: hybridEnd,
          isRefresh: false,
        );
  }

  List<DateTime> _getWeekDates() {
    final now = DateTime.now();
    final weekday = now.weekday;
    final monday = now.subtract(Duration(days: weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final appointmentsState = ref.watch(appointmentsNotifierProvider);
    final appointments = appointmentsState.appointments;
    final isLoading = appointmentsState.loadingStatus.isLoading;

    final displayCount = appointmentsState.totalCount > appointments.length
        ? appointmentsState.totalCount
        : appointments.length;

    // [LISTENERS]
    ref.listen<String>(authNotifierProvider.select((state) => state.user.id), (
      prev,
      next,
    ) {
      if (prev != null && prev.isNotEmpty && prev != next && next.isNotEmpty) {
        _isInitialLoad = true;
        _selectedDate = DateTime.now();
        _loadAppointmentsForSelectedDate();
      }
    });

    ref.listen<AsyncValue<void>>(
      appointmentsNotifierProvider.select((state) => state.loadingStatus),
      (prev, next) {
        next.whenOrNull(
          data: (_) {
            // Load xong -> Tắt hết cờ loading
            if (mounted) {
              setState(() {
                _isInitialLoad = false;
                _isSwitchingDate = false;
              });
            }
          },
          error: (err, stack) {
            if (mounted) {
              setState(() {
                _isInitialLoad = false;
                _isSwitchingDate = false;
              });
            }
            ToastUtils.showError(err.toString());
          },
        );
      },
    );

    // [LOGIC HIỂN THỊ LOADING]
    // Chỉ hiện Circle Loading ở giữa màn hình khi:
    // 1. Đang load (isLoading == true)
    // 2. VÀ (Là lần đầu load OR Đang đổi ngày)
    // -> Khi Pull-to-refresh: _isSwitchingDate = false -> Không hiện Circle Loading
    final shouldShowCenterLoading =
        isLoading && (_isInitialLoad || _isSwitchingDate);

    return Container(
      decoration: BoxDecoration(gradient: AppColors.mainBackgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            _buildHeader(displayCount),
            _buildWeekCalendar(),

            Expanded(
              child: shouldShowCenterLoading
                  ? _buildLoadingState() // Loading giữa màn hình
                  : RefreshIndicator(
                      onRefresh: () async {
                        // Khi pull refresh, ta KHÔNG set _isSwitchingDate = true
                        // Nên loading giữa màn hình sẽ KHÔNG hiện.
                        _loadAppointmentsForSelectedDate();
                      },
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (!appointmentsState.isLoadingMore &&
                              appointmentsState.hasMore &&
                              scrollInfo.metrics.pixels >=
                                  scrollInfo.metrics.maxScrollExtent - 200) {
                            _loadMoreAppointments();
                          }
                          return false;
                        },
                        child: appointments.isEmpty && !isLoading
                            ? _buildEmptyState()
                            : _buildAppointmentsList(
                                appointments,
                                appointmentsState.isLoadingMore,
                              ),
                      ),
                    ),
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

    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    return GestureDetector(
      onTap: () {
        // Nếu chọn lại ngày đang chọn thì không làm gì
        if (isSelected) return;

        setState(() {
          _selectedDate = date;
          _isSwitchingDate =
              true; // [QUAN TRỌNG] Bật cờ này để hiện Loading giữa màn hình
        });
        _loadAppointmentsForSelectedDate();
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
              onPressed: () => context.push(AppRoutes.notifications),
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
              onPressed: () => LogoutDialog.show(context),
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
    // Cho phép pull-to-refresh ngay cả khi empty
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
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

  Widget _buildAppointmentsList(
    List<AppointmentLine> appointments,
    bool isLoadingMore,
  ) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: appointments.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == appointments.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final appointment = appointments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppointmentCardApi(appointment: appointment),
        );
      },
    );
  }
}
