import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  // State variables
  String _selectedTab = 'Payment'; // Payment or Transaction
  String _selectedPeriod = 'Day'; // Day, Week, Month, Year, Custom
  DateTime _selectedDate = DateTime.now();
  
  // New variable to track the month currently visible in the calendar view
  DateTime _displayedMonthDate = DateTime.now();
  
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

  DateTime _getStartOfWeekForPage(int pageIndex) {
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday % 7));
    final weekOffset = pageIndex - _initialPage;
    return currentWeekStart.add(Duration(days: weekOffset * 7));
  }

  void _jumpToDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _displayedMonthDate = date;
    });
    
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday % 7));
    final targetWeekStart = date.subtract(Duration(days: date.weekday % 7));
    final diffInDays = targetWeekStart.difference(currentWeekStart).inDays;
    final diffInWeeks = (diffInDays / 7).round();
    final targetPage = _initialPage + diffInWeeks;
    
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        targetPage, 
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeInOut,
      );
    }
  }

  bool _hasDataForDate(DateTime date) {
    return _mockTransactions.any((t) => DateUtils.isSameDay(t['date'] as DateTime, date));
  }

  List<Map<String, dynamic>> _getTransactionsForSelectedDate() {
    return _mockTransactions.where((transaction) {
      final transactionDate = transaction['date'] as DateTime;
      return DateUtils.isSameDay(transactionDate, _selectedDate);
    }).toList();
  }

  Map<String, double> _calculateSummary(List<Map<String, dynamic>> transactions) {
    return {
      'totalEarn': transactions.fold(0.0, (sum, t) => sum + (t['totalEarn'] as double)),
      'discount': transactions.fold(0.0, (sum, t) => sum + (t['discount'] as double)),
      'tips': transactions.fold(0.0, (sum, t) => sum + (t['tips'] as double)),
      'empShare': transactions.fold(0.0, (sum, t) => sum + (t['empShare'] as double)),
    };
  }

  @override
  Widget build(BuildContext context) {
    final transactions = _getTransactionsForSelectedDate();
    final summary = _calculateSummary(transactions);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Modern Sliding Segment Control
            SliverAppBar(
              floating: true,
              pinned: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              toolbarHeight: 60,
              title: _buildSegmentedControl(),
              centerTitle: true,
            ),

            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Unified Compact Calendar Card
                  _buildCompactCalendarCard(),
                  
                  const SizedBox(height: AppDimensions.spacingS),
                  
                  // Summary Cards
                  _buildSummaryCards(summary),
                  
                  const SizedBox(height: AppDimensions.spacingM),
                ],
              ),
            ),

            // Transactions List
            if (transactions.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.spacingM,
                  0,
                  AppDimensions.spacingM,
                  100,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final transaction = transactions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.spacingS),
                        child: _buildTransactionCard(transaction, index + 1),
                      );
                    },
                    childCount: transactions.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomSummary(summary),
    );
  }

  // 1. Modern Sliding Segment Control
  Widget _buildSegmentedControl() {
    return Container(
      height: 44,
      width: 300, // Fixed width for better centering
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5), // Light grey track
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
    );
  }

  Widget _buildSegmentButton(String tab) {
    final isSelected = _selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
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

  // 2. Unified Compact Calendar Card
  Widget _buildCompactCalendarCard() {
    return Container(
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
          // Row 1: Month Nav (Left) + Today Button (Right)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Month Title & Nav
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        final prevMonth = DateTime(_displayedMonthDate.year, _displayedMonthDate.month - 1, 1);
                        _jumpToDate(prevMonth);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[100],
                        ),
                        child: Icon(Icons.chevron_left, color: Colors.grey[700], size: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        DateFormat('MMMM yyyy').format(_displayedMonthDate),
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        final nextMonth = DateTime(_displayedMonthDate.year, _displayedMonthDate.month + 1, 1);
                        _jumpToDate(nextMonth);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[100],
                        ),
                        child: Icon(Icons.chevron_right, color: Colors.grey[700], size: 18),
                      ),
                    ),
                  ],
                ),
                
                // Today Button
                GestureDetector(
                  onTap: () => _jumpToDate(DateTime.now()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                    ),
                    child: Text(
                      'Today',
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

          // Row 2: Period Selector (All fit in one row, equal width)
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

          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 8),

          _buildCompactCalendar(),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildExpandedPeriodChip(String period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = period),
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

  // Removed _buildTodayChip as it's now integrated in Row 1

  Widget _buildCompactCalendar() {
    return SizedBox(
      height: 60,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          final weekStart = _getStartOfWeekForPage(index);
          final midWeek = weekStart.add(const Duration(days: 3));
          if (midWeek.month != _displayedMonthDate.month || midWeek.year != _displayedMonthDate.year) {
            setState(() => _displayedMonthDate = midWeek);
          }
        },
        itemBuilder: (context, index) {
          final weekStart = _getStartOfWeekForPage(index);
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (dayIndex) {
              final date = weekStart.add(Duration(days: dayIndex));
              final isSelected = DateUtils.isSameDay(date, _selectedDate);
              final isToday = DateUtils.isSameDay(date, DateTime.now());
              final hasData = _hasDataForDate(date);

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                      _displayedMonthDate = date;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.primary 
                          : (isToday ? AppColors.primary.withValues(alpha: 0.05) : Colors.transparent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(date).toUpperCase().substring(0, 1),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[500],
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('d').format(date),
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
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
                              color: isSelected ? Colors.white : AppColors.primary,
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

  // Summary Cards
  Widget _buildSummaryCards(Map<String, double> summary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingM),
      child: Row(
        children: [
          Expanded(child: _buildSummaryCard('Total', summary['totalEarn']!, AppColors.primary)),
          const SizedBox(width: 8),
          Expanded(child: _buildSummaryCard('Share', summary['empShare']!, AppColors.secondary)),
          const SizedBox(width: 8),
          Expanded(child: _buildSummaryCard('Tips', summary['tips']!, AppColors.accent)),
        ],
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
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

  Widget _buildTransactionCard(Map<String, dynamic> transaction, int index) {
    final services = transaction['services'] as List<String>;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '#$index',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          title: Text(
            'Ticket #${transaction['ticketNumber']}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          subtitle: _selectedTab == 'Payment'
              ? Text(
                  services.join(', '),
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: Text(
            '\$${transaction['totalEarn'].toStringAsFixed(0)}',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                children: [
                  const Divider(height: 12),
                  _buildDetailRow('Discount', '\$${transaction['discount']}'),
                  _buildDetailRow('Tips', '\$${transaction['tips']}'),
                  _buildDetailRow('Your Share', '\$${transaction['empShare']}', isBold: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppColors.primary : Colors.black87,
              fontSize: 12,
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
          Icon(
            Icons.receipt_long_rounded,
            size: 48,
            color: Colors.grey[300],
          ),
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
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