import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/date_range_picker_bottom_sheet.dart';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  // State variables
  String _selectedTab = 'Payment';
  String _selectedPeriod = 'Day';
  DateTime _selectedDate = DateTime.now();

  // Tracks the visible month/year in the calendar view
  DateTime _displayedDate = DateTime.now();

  // Custom date range
  DateTime _customFromDate = DateTime.now();
  DateTime _customToDate = DateTime.now();

  final int _initialPage = 1000;
  late final PageController _pageController;

  // Mock data for testing
  final List<Map<String, dynamic>> _mockTransactions = [
    {
      'id': '1',
      'ticketNumber': '00003',
      'services': ['Gel Manicure', 'Nail Art'],
      'totalEarn': 35.0,
      'discount': 0.0,
      'tips': 0.0,
      'empShare': 21.0,
      'date': DateTime(2025, 12, 26),
    },
    {
      'id': '2',
      'ticketNumber': '00001',
      'services': ['Acrylic Full Set'],
      'totalEarn': 35.0,
      'discount': 0.0,
      'tips': 0.0,
      'empShare': 21.0,
      'date': DateTime(2025, 12, 26),
    },
    {
      'id': '3',
      'ticketNumber': '00005',
      'services': ['Pedicure Deluxe', 'Foot Massage'],
      'totalEarn': 55.0,
      'discount': 5.0,
      'tips': 10.0,
      'empShare': 33.0,
      'date': DateTime(2025, 12, 25),
    },
    {
      'id': '4',
      'ticketNumber': '00008',
      'services': ['Manicure'],
      'totalEarn': 25.0,
      'discount': 0.0,
      'tips': 5.0,
      'empShare': 15.0,
      'date': DateTime(2025, 12, 26),
    },
    {
      'id': '5',
      'ticketNumber': '00012',
      'services': ['Brows Wax'],
      'totalEarn': 15.0,
      'discount': 0.0,
      'tips': 2.0,
      'empShare': 10.0,
      'date': DateTime(2025, 12, 26),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // --- Logic Helpers ---

  DateTime _getStartOfWeekForPage(int pageIndex) {
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday % 7));
    final weekOffset = pageIndex - _initialPage;
    return currentWeekStart.add(Duration(days: weekOffset * 7));
  }

  void _jumpToDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _displayedDate = date;
    });

    if (_selectedPeriod == 'Day' && _pageController.hasClients) {
      final now = DateTime.now();
      final currentWeekStart = now.subtract(Duration(days: now.weekday % 7));
      final targetWeekStart = date.subtract(Duration(days: date.weekday % 7));
      final diffInDays = targetWeekStart.difference(currentWeekStart).inDays;
      final diffInWeeks = (diffInDays / 7).round();
      final targetPage = _initialPage + diffInWeeks;

      _pageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _hasDataForDate(DateTime date) {
    return _mockTransactions.any(
      (t) => DateUtils.isSameDay(t['date'] as DateTime, date),
    );
  }

  List<Map<String, dynamic>> _getTransactionsForSelectedDate() {
    return _mockTransactions.where((transaction) {
      final transactionDate = transaction['date'] as DateTime;

      if (_selectedPeriod == 'Day') {
        return DateUtils.isSameDay(transactionDate, _selectedDate);
      } else if (_selectedPeriod == 'Week') {
        // Week starts on _selectedDate (Sunday) and ends 6 days later
        final weekEnd = _selectedDate.add(const Duration(days: 6));
        // Use inclusive comparison logic
        return !transactionDate.isBefore(_selectedDate) &&
            !transactionDate.isAfter(weekEnd.add(const Duration(seconds: 1)));
      } else if (_selectedPeriod == 'Month') {
        return transactionDate.month == _selectedDate.month &&
            transactionDate.year == _selectedDate.year;
      } else if (_selectedPeriod == 'Year') {
        return transactionDate.year == _selectedDate.year;
      } else if (_selectedPeriod == 'Custom') {
        // Filter transactions within custom date range (inclusive)
        final fromDate = DateTime(
          _customFromDate.year,
          _customFromDate.month,
          _customFromDate.day,
        );
        final toDate = DateTime(
          _customToDate.year,
          _customToDate.month,
          _customToDate.day,
          23,
          59,
          59,
        );
        return !transactionDate.isBefore(fromDate) &&
            !transactionDate.isAfter(toDate);
      }
      return DateUtils.isSameDay(transactionDate, _selectedDate);
    }).toList();
  }

  Map<String, double> _calculateSummary(
    List<Map<String, dynamic>> transactions,
  ) {
    return {
      'totalEarn': transactions.fold(
        0.0,
        (sum, t) => sum + (t['totalEarn'] as double),
      ),
      'discount': transactions.fold(
        0.0,
        (sum, t) => sum + (t['discount'] as double),
      ),
      'tips': transactions.fold(0.0, (sum, t) => sum + (t['tips'] as double)),
      'empShare': transactions.fold(
        0.0,
        (sum, t) => sum + (t['empShare'] as double),
      ),
    };
  }

  // --- Header Navigation Logic ---

  String _getHeaderTitle() {
    if (_selectedPeriod == 'Day' || _selectedPeriod == 'Week') {
      return DateFormat('MMMM yyyy').format(_displayedDate);
    } else {
      return DateFormat('yyyy').format(_displayedDate);
    }
  }

  void _onHeaderPrev() {
    setState(() {
      if (_selectedPeriod == 'Day' || _selectedPeriod == 'Week') {
        _displayedDate = DateTime(
          _displayedDate.year,
          _displayedDate.month - 1,
          1,
        );
        _selectedDate = _displayedDate;
      } else {
        _displayedDate = DateTime(_displayedDate.year - 1, 1, 1);
        _selectedDate = _displayedDate;
      }
    });
    if (_selectedPeriod == 'Day') _jumpToDate(_displayedDate);
  }

  void _onHeaderNext() {
    setState(() {
      if (_selectedPeriod == 'Day' || _selectedPeriod == 'Week') {
        _displayedDate = DateTime(
          _displayedDate.year,
          _displayedDate.month + 1,
          1,
        );
        _selectedDate = _displayedDate;
      } else {
        _displayedDate = DateTime(_displayedDate.year + 1, 1, 1);
        _selectedDate = _displayedDate;
      }
    });
    if (_selectedPeriod == 'Day') _jumpToDate(_displayedDate);
  }

  Future<void> _openDateRangePicker() async {
    final result = await showModalBottomSheet<Map<String, DateTime?>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DateRangePickerBottomSheet(
        initialFromDate: _customFromDate,
        initialToDate: _customToDate,
      ),
    );

    if (result != null &&
        result['fromDate'] != null &&
        result['toDate'] != null) {
      setState(() {
        _customFromDate = result['fromDate']!;
        _customToDate = result['toDate']!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = _getTransactionsForSelectedDate();
    final summary = _calculateSummary(transactions);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // --- FIXED HEADER SECTION ---
            Container(
              color: AppColors.background,
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  // 1. Segmented Control
                  _buildSegmentedControl(),

                  const SizedBox(height: 12),

                  // 2. Calendar Card
                  _buildCompactCalendarCard(),

                  const SizedBox(height: 12),
                ],
              ),
            ),

            // --- SCROLLABLE LIST SECTION ---
            Expanded(
              child: transactions.isEmpty
                  ? _buildEmptyState()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        0,
                        0,
                        0,
                        20, // Bottom padding
                      ),
                      physics: const ClampingScrollPhysics(),
                      child: _buildTicketTable(transactions, summary),
                    ),
            ),
          ],
        ),
      ),
      // Removed bottom TOTAL summary bar
      // bottomNavigationBar: _buildBottomSummary(summary),
    );
  }

  Widget _buildSegmentedControl() {
    return RepaintBoundary(
      child: Container(
        height: 44,
        width: 300,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _buildSegmentButton('Payment'),
            _buildSegmentButton('Transaction'),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton(String tab) {
    final isSelected = _selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedTab != tab) {
            setState(() => _selectedTab = tab);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? Colors.black.withValues(alpha: 0.08)
                    : Colors.transparent,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            tab,
            style: AppTextStyles.labelLarge.copyWith(
              color: isSelected ? AppColors.primary : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCalendarCard() {
    final bool showBottomCalendar =
        _selectedPeriod != 'Year' && _selectedPeriod != 'Custom';

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _selectedPeriod == 'Custom'
                  ? Center(child: _buildCustomDateSelector())
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: _onHeaderPrev,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[100],
                                ),
                                child: Icon(
                                  Icons.chevron_left,
                                  color: Colors.grey[700],
                                  size: 18,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                _getHeaderTitle(),
                                style: AppTextStyles.titleLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: _onHeaderNext,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[100],
                                ),
                                child: Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey[700],
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Dynamic Today/This Week/etc Button
                        GestureDetector(
                          onTap: () => _jumpToDate(DateTime.now()),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Text(
                              _selectedPeriod == 'Day'
                                  ? 'Today'
                                  : _selectedPeriod == 'Week'
                                  ? 'This Week'
                                  : _selectedPeriod == 'Month'
                                  ? 'This Month'
                                  : _selectedPeriod == 'Year'
                                  ? 'This Year'
                                  : 'Today',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildExpandedPeriodChip('Day'),
                  const SizedBox(width: 4),
                  _buildExpandedPeriodChip('Week'),
                  const SizedBox(width: 4),
                  _buildExpandedPeriodChip('Month'),
                  const SizedBox(width: 4),
                  _buildExpandedPeriodChip('Year'),
                  const SizedBox(width: 4),
                  _buildExpandedPeriodChip('Custom'),
                ],
              ),
            ),

            if (showBottomCalendar) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 8),
              _buildDynamicCalendarBody(),
              const SizedBox(height: 8),
            ] else
              const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedPeriodChip(String period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedPeriod = period);
          if (period == 'Day') _jumpToDate(_selectedDate);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            period,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDateSelector() {
    return GestureDetector(
      onTap: _openDateRangePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, size: 13, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'From: ${DateFormat('MMM d, yyyy').format(_customFromDate)}',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(
                Icons.arrow_forward,
                size: 10,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
            Text(
              'To: ${DateFormat('MMM d, yyyy').format(_customToDate)}',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.edit, size: 12, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicCalendarBody() {
    if (_selectedPeriod == 'Week') {
      return _buildWeekView();
    } else if (_selectedPeriod == 'Month') {
      return _buildMonthView();
    } else {
      return _buildDayView();
    }
  }

  Widget _buildDayView() {
    final now = DateTime.now();
    return SizedBox(
      height: 60,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          final weekStart = _getStartOfWeekForPage(index);
          final midWeek = weekStart.add(const Duration(days: 3));
          if (midWeek.month != _displayedDate.month ||
              midWeek.year != _displayedDate.year) {
            setState(() => _displayedDate = midWeek);
          }
        },
        itemBuilder: (context, index) {
          final weekStart = _getStartOfWeekForPage(index);
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (dayIndex) {
              final date = weekStart.add(Duration(days: dayIndex));
              final isSelected = DateUtils.isSameDay(date, _selectedDate);
              final isToday = DateUtils.isSameDay(date, now);
              final hasData = _hasDataForDate(date);

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                      _displayedDate = date;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : (isToday
                                ? AppColors.primary.withValues(alpha: 0.05)
                                : Colors.transparent),
                      borderRadius: BorderRadius.circular(12),
                      border: isToday && !isSelected
                          ? Border.all(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat(
                            'E',
                          ).format(date).toUpperCase().substring(0, 1),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isToday
                                      ? AppColors.primary
                                      : Colors.grey[500]),
                            fontSize: 9,
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('d').format(date),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (hasData)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          )
                        else
                          const SizedBox(height: 3),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildWeekView() {
    final now = DateTime.now();
    final currentWeekStartAnchor = now.subtract(
      Duration(days: now.weekday % 7),
    );

    final weeks = <DateTime>[];
    var d = DateTime(_displayedDate.year, _displayedDate.month, 1);
    var weekStart = d.subtract(Duration(days: d.weekday % 7));

    while (weekStart.month == _displayedDate.month ||
        weekStart.add(const Duration(days: 6)).month == _displayedDate.month) {
      if (weeks.isNotEmpty && weeks.last.isAtSameMomentAs(weekStart)) break;
      weeks.add(weekStart);
      weekStart = weekStart.add(const Duration(days: 7));
    }

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: weeks.length,
        itemBuilder: (context, index) {
          final start = weeks[index];
          final end = start.add(const Duration(days: 6));

          final isSelected = DateUtils.isSameDay(
            start,
            _selectedDate.subtract(Duration(days: _selectedDate.weekday % 7)),
          );
          final isCurrentWeek = DateUtils.isSameDay(
            start,
            currentWeekStartAnchor,
          );

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = start),
            child: Container(
              width: 85,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isCurrentWeek
                          ? AppColors.primary.withValues(alpha: 0.05)
                          : Colors.transparent),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isCurrentWeek ? AppColors.primary : Colors.grey[200]!),
                  width: isCurrentWeek ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Week ${index + 1}',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isCurrentWeek
                                ? AppColors.primary
                                : Colors.grey[600]),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('MMM d').format(start)} - ${DateFormat('d').format(end)}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
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

  Widget _buildMonthView() {
    final now = DateTime.now();
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 12,
        itemBuilder: (context, index) {
          final monthIndex = index + 1;
          final isSelected =
              _selectedDate.month == monthIndex &&
              _selectedDate.year == _displayedDate.year;
          final isCurrentMonth =
              now.month == monthIndex && now.year == _displayedDate.year;

          return GestureDetector(
            onTap: () => setState(
              () =>
                  _selectedDate = DateTime(_displayedDate.year, monthIndex, 1),
            ),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isCurrentMonth
                          ? AppColors.primary.withValues(alpha: 0.05)
                          : Colors.transparent),
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? null
                    : Border.all(
                        color: isCurrentMonth
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : Colors.grey[200]!,
                      ),
              ),
              alignment: Alignment.center,
              child: Text(
                DateFormat('MMM').format(DateTime(2022, monthIndex)),
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isCurrentMonth
                            ? AppColors.primary
                            : AppColors.textPrimary),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, double> summary) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingM),
        child: Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total',
                summary['totalEarn']!,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSummaryCard(
                'Share',
                summary['empShare']!,
                AppColors.secondary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSummaryCard(
                'Tips',
                summary['tips']!,
                AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '\$${value.toStringAsFixed(0)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTicketTable(
    List<Map<String, dynamic>> transactions,
    Map<String, double> summary,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          ...transactions.asMap().entries.map((entry) {
            return _buildTableRow(entry.value, entry.key + 1);
          }),
          // Add total row for both tabs
          _buildTotalRow(summary),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    final isPaymentTab = _selectedTab == 'Payment';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: isPaymentTab
            ? [
                // Payment tab: 6 columns
                _buildHeaderCell('#', flex: 1),
                _buildHeaderCell('Ticket', flex: 2),
                _buildHeaderCell('Total\nEarn', flex: 2),
                _buildHeaderCell('Disc', flex: 2),
                _buildHeaderCell('Tips', flex: 2),
                _buildHeaderCell('Emp \$', flex: 2),
              ]
            : [
                // Transaction tab: 3 columns
                _buildHeaderCell('#', flex: 1),
                _buildHeaderCell('Ticket', flex: 2),
                _buildHeaderCell('Services', flex: 6),
                _buildHeaderCell('Total', flex: 2),
              ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildTableRow(
    Map<String, dynamic> transaction,
    int index,
  ) {
    final isPaymentTab = _selectedTab == 'Payment';

    // Hiển thị "-" nếu giá trị = 0
    String formatValue(double value) {
      return value == 0 ? '-' : value.toStringAsFixed(0);
    }

    // Format services for Transaction tab
    String formatServices(List<dynamic> services) {
      if (services.isEmpty) return '-';
      return services.map((s) => '- $s').join('\n');
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.white : Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isPaymentTab
            ? [
                // Payment tab: 6 columns
                _buildDataCell('$index', flex: 1),
                _buildDataCell(transaction['ticketNumber'], flex: 2),
                _buildDataCell(
                  transaction['totalEarn'].toStringAsFixed(0),
                  flex: 2,
                ),
                _buildDataCell(formatValue(transaction['discount']), flex: 2),
                _buildDataCell(formatValue(transaction['tips']), flex: 2),
                _buildDataCell(
                  transaction['empShare'].toStringAsFixed(0),
                  flex: 2,
                ),
              ]
            : [
                // Transaction tab: 3 columns
                _buildDataCell('$index', flex: 1),
                _buildDataCell(transaction['ticketNumber'], flex: 2),
                _buildDataCell(
                  formatServices(transaction['services'] as List),
                  flex: 6,
                  isMultiline: true,
                ),
                _buildDataCell(
                  transaction['totalEarn'].toStringAsFixed(0),
                  flex: 2,
                ),
              ],
      ),
    );
  }

  Widget _buildDataCell(String text, {int flex = 1, bool isMultiline = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: isMultiline ? TextAlign.left : TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: text == '-' ? Colors.grey[400] : Colors.grey[800],
          fontWeight: text == '-' ? FontWeight.normal : FontWeight.w500,
        ),
        maxLines: isMultiline ? null : 1,
        overflow: isMultiline ? null : TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTotalRow(Map<String, double> summary) {
    final isPaymentTab = _selectedTab == 'Payment';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(top: BorderSide(color: AppColors.primary, width: 2)),
      ),
      child: Row(
        children: isPaymentTab
            ? [
                // Payment tab: Show Total, Disc, Tips, Emp $ in respective columns
                Expanded(flex: 1, child: Container()), // # column
                Expanded(flex: 2, child: Container()), // Ticket column
                Expanded(
                  flex: 2,
                  child: Text(
                    '\$${summary['totalEarn']!.toStringAsFixed(0)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    summary['discount']! > 0
                        ? '\$${summary['discount']!.toStringAsFixed(0)}'
                        : '-',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '\$${summary['tips']!.toStringAsFixed(0)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '\$${summary['empShare']!.toStringAsFixed(0)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]
            : [
                // Transaction tab: Show only total
                Expanded(flex: 1, child: Container()), // # column
                Expanded(
                  flex: 2,
                  child: Text(
                    'TOTAL',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(flex: 6, child: Container()), // Services column
                Expanded(
                  flex: 2,
                  child: Text(
                    summary['totalEarn']!.toStringAsFixed(0),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text(
            'No Data',
            style: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummary(Map<String, double> summary) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  fontSize: 13,
                ),
              ),
              Text(
                '\$${summary['totalEarn']!.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
