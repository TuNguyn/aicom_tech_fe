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
  ];

  List<DateTime> _getWeekDates() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
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
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header with Payment/Transaction tabs
          _buildHeader(),

          // Time period selector
          _buildPeriodSelector(),

          // Month navigation
          _buildMonthNavigation(),

          // Week calendar selector
          _buildWeekCalendar(),

          // Summary stats cards
          _buildSummaryCards(summary),

          // Transactions list
          Expanded(
            child: transactions.isEmpty
                ? _buildEmptyState()
                : _buildTransactionsList(transactions),
          ),

          // Bottom summary bar
          _buildBottomSummary(summary),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingM,
        AppDimensions.spacingXs,
        AppDimensions.spacingM,
        AppDimensions.spacingS,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _buildTabButton('Payment'),
            ),
            Expanded(
              child: _buildTabButton('Transaction'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String tab) {
    final isSelected = _selectedTab == tab;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tab;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00BCD4) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          tab,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? Colors.white : const Color(0xFF00BCD4),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['Day', 'Week', 'Month', 'Year', 'Custom'];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingXs,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.all(3),
        child: Row(
          children: periods.map((period) {
            final isSelected = _selectedPeriod == period;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPeriod = period;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF5C6BC0) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    period,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMonthNavigation() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingXs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Color(0xFF5C6BC0)),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month - 1,
                  _selectedDate.day,
                );
              });
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(_selectedDate),
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Color(0xFF5C6BC0)),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month + 1,
                  _selectedDate.day,
                );
              });
            },
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = DateTime.now();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF5C6BC0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Today',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
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

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF5C6BC0)
                      : (isToday ? const Color(0xFF5C6BC0).withValues(alpha: 0.1) : Colors.transparent),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF5C6BC0)
                        : (isToday ? const Color(0xFF5C6BC0).withValues(alpha: 0.3) : Colors.transparent),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('E').format(date).substring(0, 3),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isToday ? const Color(0xFF5C6BC0) : Colors.grey[600]),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('d').format(date),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, double> summary) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingM,
        AppDimensions.spacingS,
        AppDimensions.spacingM,
        AppDimensions.spacingS,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Earn',
              '\$${summary['totalEarn']!.toStringAsFixed(0)}',
              Icons.monetization_on_outlined,
              AppColors.primary,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Expanded(
            child: _buildSummaryCard(
              'Your Share',
              '\$${summary['empShare']!.toStringAsFixed(0)}',
              Icons.account_balance_wallet_outlined,
              AppColors.secondary,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Expanded(
            child: _buildSummaryCard(
              'Tips',
              '\$${summary['tips']!.toStringAsFixed(0)}',
              Icons.volunteer_activism_outlined,
              AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingS),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.grey[700],
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(List<Map<String, dynamic>> transactions) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingM,
        AppDimensions.spacingS,
        AppDimensions.spacingM,
        AppDimensions.spacingM,
      ),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.spacingS),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionCard(transaction, index + 1);
      },
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction, int index) {
    final services = transaction['services'] as List<String>;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.primary.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingS),
        child: Column(
          children: [
            // Header row with ticket number and total
            Row(
              children: [
                // Index badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.2),
                        AppColors.secondary.withValues(alpha: 0.2),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ticket #${transaction['ticketNumber']}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (_selectedTab == 'Payment')
                        Text(
                          services.join(' + '),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '\$${transaction['totalEarn'].toStringAsFixed(0)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            // Transaction details (only for Transaction tab)
            if (_selectedTab == 'Transaction') ...[
              const SizedBox(height: AppDimensions.spacingS),
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingS),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDetailItem('Disc', '\$${transaction['discount'].toStringAsFixed(0)}'),
                    Container(width: 1, height: 20, color: Colors.grey[300]),
                    _buildDetailItem('Tips', '\$${transaction['tips'].toStringAsFixed(0)}'),
                    Container(width: 1, height: 20, color: Colors.grey[300]),
                    _buildDetailItem('Your Share', '\$${transaction['empShare'].toStringAsFixed(0)}'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.grey[600],
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
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
                Icons.receipt_long_outlined,
                size: 50,
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            Text(
              'No Transactions',
              style: AppTextStyles.headlineLarge.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              'No transactions found for the selected date',
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

  Widget _buildBottomSummary(Map<String, double> summary) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF00BCD4),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00BCD4).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _selectedTab == 'Payment'
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'SUM',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Text(
                        '\$${summary['totalEarn']!.toStringAsFixed(0)}',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'SUM',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildValue(summary['totalEarn']!),
                      const SizedBox(width: 16),
                      _buildValue(summary['discount']!),
                      const SizedBox(width: 16),
                      _buildValue(summary['tips']!),
                      const SizedBox(width: 16),
                      _buildValue(summary['empShare']!),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildValue(double value) {
    final displayValue = value == 0 ? '-' : value.toStringAsFixed(0);
    return Text(
      displayValue,
      style: AppTextStyles.bodyMedium.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
    );
  }

}
