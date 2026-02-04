import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app_dependencies.dart';
import '../../../routes/app_routes.dart';
import '../../../domain/entities/walk_in_ticket.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/logout_dialog.dart';
import '../appointments/appointments_page.dart';
import '../report/report_page.dart';
import '../more/more_page.dart';
import '../walk_in/walk_in_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentNavIndex = 0;
  bool _isDataLoaded = false;

  // Mock data for notifications
  static final List<Map<String, dynamic>> _mockNotifications = [
    {
      'title': 'Appointment Reminder',
      'message': 'Sarah Johnson at 10:00 AM',
      'time': '5m ago',
      'icon': Icons.event_available,
      'color': AppColors.primary,
    },
    {
      'title': 'New Walk-in Customer',
      'message': 'Customer waiting at front desk',
      'time': '12m ago',
      'icon': Icons.person_add_outlined,
      'color': AppColors.accent,
    },
    {
      'title': 'Payment Received',
      'message': 'Ticket #00003 - \$35.00',
      'time': '1h ago',
      'icon': Icons.payment,
      'color': AppColors.success,
    },
    {
      'title': 'Appointment Cancelled',
      'message': 'Maria Garcia cancelled 2:30 PM slot',
      'time': '2h ago',
      'icon': Icons.event_busy,
      'color': AppColors.error,
    },
    {
      'title': 'New Review',
      'message': 'Jennifer Smith left a 5-star review',
      'time': '3h ago',
      'icon': Icons.star,
      'color': Colors.amber,
    },
    {
      'title': 'Stock Alert',
      'message': 'Gel polish running low - reorder needed',
      'time': '4h ago',
      'icon': Icons.inventory_2_outlined,
      'color': AppColors.warning,
    },
  ];

  static const _overlayStyleHome = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  static const _overlayStyleWalkIn = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  static final _overlayStyleAppointments = SystemUiOverlayStyle(
    statusBarColor: AppColors.primary,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  static const _overlayStyleReport = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  static final _overlayStyleMore = SystemUiOverlayStyle(
    statusBarColor: AppColors.primary,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  SystemUiOverlayStyle get _currentOverlayStyle {
    switch (_currentNavIndex) {
      case 0:
        return _overlayStyleHome;
      case 1:
        return _overlayStyleWalkIn;
      case 2:
        return _overlayStyleAppointments;
      case 3:
        return _overlayStyleReport;
      case 4:
        return _overlayStyleMore;
      default:
        return _overlayStyleHome;
    }
  }

  // Hàm load dữ liệu chính cho trang Home
  void _loadHomeData() {
    Future.wait([
      ref.read(appointmentsNotifierProvider.notifier).fetchTodayCount(),
      ref.read(walkInsNotifierProvider.notifier).loadWalkIns(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _currentOverlayStyle,
      child: Container(
        decoration: BoxDecoration(gradient: AppColors.mainBackgroundGradient),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: IndexedStack(
            index: _currentNavIndex,
            children: [
              _HomeContent(
                loadHomeData: _loadHomeData,
                isDataLoaded: _isDataLoaded,
                onDataLoaded: (loaded) {
                  // Dùng microtask để tránh lỗi setState trong khi build
                  Future.microtask(() {
                    if (mounted) {
                      setState(() {
                        _isDataLoaded = loaded;
                      });
                    }
                  });
                },
                mockNotifications: _mockNotifications,
              ),
              const WalkInPage(),
              const AppointmentsPage(),
              const ReportPage(),
              const MorePage(),
            ],
          ),
          bottomNavigationBar: BottomNavBar(
            currentIndex: _currentNavIndex,
            useWhiteBackground:
                (_currentNavIndex == 2 ||
                _currentNavIndex == 3 ||
                _currentNavIndex == 4),
            onTap: (index) {
              setState(() {
                _currentNavIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}

/// Separate widget for home content to support AutomaticKeepAliveClientMixin
class _HomeContent extends ConsumerStatefulWidget {
  final VoidCallback loadHomeData;
  final bool isDataLoaded;
  final ValueChanged<bool> onDataLoaded;
  final List<Map<String, dynamic>> mockNotifications;

  const _HomeContent({
    required this.loadHomeData,
    required this.isDataLoaded,
    required this.onDataLoaded,
    required this.mockNotifications,
  });

  @override
  ConsumerState<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<_HomeContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Load data only if not loaded yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.isDataLoaded) {
        widget.loadHomeData();
        widget.onDataLoaded(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Listen to auth changes to reload data on login
    ref.listen<String>(authNotifierProvider.select((state) => state.user.id), (
      previous,
      next,
    ) {
      if (previous != null &&
          previous.isNotEmpty &&
          previous != next &&
          next.isNotEmpty) {
        widget.onDataLoaded(false);
        widget.loadHomeData();
        widget.onDataLoaded(true);
      }
    });

    return Column(
      children: [
        _buildHeader(context, ref),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spacingM,
              AppDimensions.spacingM,
              AppDimensions.spacingM,
              100, // Padding for bottom nav
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notifications Section
                _buildNotificationsSection(context),
                const SizedBox(height: AppDimensions.spacingL),

                // Quick Stats Section
                _buildQuickStatsSection(ref),
                const SizedBox(height: AppDimensions.spacingL),

                // Combined Today's Summary & Performance
                _buildCombinedSummaryPerformance(ref),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Container(
      color: Colors.transparent,
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
              child: Center(
                child: Text(
                  user.fullName,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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

  Widget _buildQuickStatsSection(WidgetRef ref) {
    // Watch providers
    final appointmentsState = ref.watch(appointmentsNotifierProvider);
    final walkInsState = ref.watch(walkInsNotifierProvider);

    // [UPDATED] Lấy số lượng từ totalCount của state
    // Vì _loadHomeData đã gọi API lọc theo ngày hôm nay, nên totalCount chính là số lượng hôm nay
    final todayApptCount = appointmentsState.todayCount;

    // Lấy số lượng Waiting từ Walk-in State
    final serviceLines = walkInsState.sortedServiceLines;
    final waitingCount = serviceLines
        .where((line) => line.serviceLine.status == WalkInLineStatus.waiting)
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.event_available,
            title: 'Appointments',
            value: '$todayApptCount',
            subtitle: null,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingM),
        Expanded(
          child: _buildStatCard(
            icon: Icons.people_outline,
            title: 'Waiting',
            value: '$waitingCount',
            subtitle: null,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String? subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            value,
            style: AppTextStyles.displayLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[500]),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Notifications',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.push(AppRoutes.notifications);
                },
                child: Text(
                  'View All',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingS),
          SizedBox(
            height: 3 * 60.0,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: widget.mockNotifications.length,
              physics:
                  const NeverScrollableScrollPhysics(), // Disable inner scroll
              itemBuilder: (context, index) {
                final notification = widget.mockNotifications[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (notification['color'] as Color).withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            notification['icon'] as IconData,
                            color: notification['color'] as Color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingS),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification['title'] as String,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                notification['message'] as String,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          notification['time'] as String,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedSummaryPerformance(WidgetRef ref) {
    // Lấy state từ WalkIns Provider
    final walkInsState = ref.watch(walkInsNotifierProvider);

    // Tính toán summary từ list line đã có
    final allLines = walkInsState.allServiceLines;

    final completedCount = allLines
        .where((line) => line.serviceLine.status == WalkInLineStatus.done)
        .length;
    final inProgressCount = allLines
        .where((line) => line.serviceLine.status == WalkInLineStatus.serving)
        .length;
    final canceledCount = allLines
        .where((line) => line.serviceLine.status == WalkInLineStatus.canceled)
        .length;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Summary',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          // Completed and In Progress only
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                icon: Icons.check_circle,
                label: 'Completed',
                value: '$completedCount',
                color: AppColors.success,
              ),
              _buildSummaryItem(
                icon: Icons.access_time,
                label: 'In Progress',
                value: '$inProgressCount',
                color: AppColors.warning,
              ),
              _buildSummaryItem(
                icon: Icons.cancel,
                label: 'Cancelled',
                value: '$canceledCount',
                color: AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          // Total Turns
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              border: Border.all(color: Colors.grey[300]!, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.autorenew, color: AppColors.secondary, size: 20),
                const SizedBox(width: AppDimensions.spacingS),
                Text(
                  'Total Turns: ',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  // [UPDATED] Lấy totalTurn từ State
                  '${walkInsState.totalTurn}',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
