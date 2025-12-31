import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

enum SelectionMode { selectingFrom, selectingTo, complete }

class DateRangePickerBottomSheet extends StatefulWidget {
  final DateTime initialFromDate;
  final DateTime initialToDate;

  const DateRangePickerBottomSheet({
    super.key,
    required this.initialFromDate,
    required this.initialToDate,
  });

  @override
  State<DateRangePickerBottomSheet> createState() =>
      _DateRangePickerBottomSheetState();
}

class _DateRangePickerBottomSheetState
    extends State<DateRangePickerBottomSheet> {
  late DateTime _currentMonth;
  DateTime? _selectedFromDate;
  DateTime? _selectedToDate;
  SelectionMode _selectionMode = SelectionMode.selectingFrom;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(
      widget.initialFromDate.year,
      widget.initialFromDate.month,
      1,
    );
    _selectedFromDate = widget.initialFromDate;
    _selectedToDate = widget.initialToDate;

    // If both dates already selected, ready to modify
    if (_selectedFromDate != null && _selectedToDate != null) {
      _selectionMode = SelectionMode.complete;
    }
  }

  // Navigation methods
  void _onPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _onNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  // Selection logic
  void _onDateTap(DateTime date) {
    // Add haptic feedback
    HapticFeedback.selectionClick();

    setState(() {
      if (_selectionMode == SelectionMode.selectingFrom ||
          _selectionMode == SelectionMode.complete) {
        // Start new selection
        _selectedFromDate = date;
        _selectedToDate = null;
        _selectionMode = SelectionMode.selectingTo;
      } else if (_selectionMode == SelectionMode.selectingTo) {
        // Complete selection
        _selectedToDate = date;

        // Auto-validate: swap if To < From
        if (_selectedToDate!.isBefore(_selectedFromDate!)) {
          final temp = _selectedFromDate;
          _selectedFromDate = _selectedToDate;
          _selectedToDate = temp;
        }

        _selectionMode = SelectionMode.complete;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedFromDate = null;
      _selectedToDate = null;
      _selectionMode = SelectionMode.selectingFrom;
    });
  }

  void _applySelection() {
    if (_selectedFromDate == null || _selectedToDate == null) return;

    Navigator.pop(context, {
      'fromDate': _selectedFromDate,
      'toDate': _selectedToDate,
    });
  }

  // Helper methods
  bool _isDateInRange(DateTime date) {
    if (_selectedFromDate == null || _selectedToDate == null) return false;
    return date.isAfter(_selectedFromDate!) && date.isBefore(_selectedToDate!);
  }

  bool _isSameDate(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return DateUtils.isSameDay(a, b);
  }

  List<DateTime> _getDaysInMonth() {
    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);

    // Start from Sunday of the week containing the first day
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday
    final startDate = firstDayOfMonth.subtract(Duration(days: firstWeekday));

    // Generate 42 days (6 weeks)
    final days = <DateTime>[];
    for (int i = 0; i < 42; i++) {
      days.add(startDate.add(Duration(days: i)));
    }

    return days;
  }

  // Build methods
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingM,
        AppDimensions.spacingM,
        AppDimensions.spacingS,
        AppDimensions.spacingM,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Select Date Range',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey[600]),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: _onPreviousMonth,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[100],
              ),
              child: Icon(Icons.chevron_left, color: Colors.grey[700], size: 20),
            ),
          ),
          Text(
            DateFormat('MMMM yyyy').format(_currentMonth),
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          InkWell(
            onTap: _onNextMonth,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[100],
              ),
              child: Icon(Icons.chevron_right, color: Colors.grey[700], size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysOfWeekRow() {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: days
            .map((day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final days = _getDaysInMonth();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingM),
      child: SizedBox(
        height: 280,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
            crossAxisSpacing: 4,
            mainAxisSpacing: 6,
          ),
          itemCount: 42,
          itemBuilder: (context, index) => _buildDateCell(days[index]),
        ),
      ),
    );
  }

  Widget _buildDateCell(DateTime date) {
    final isCurrentMonth = date.month == _currentMonth.month &&
        date.year == _currentMonth.year;
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final isFromDate = _isSameDate(date, _selectedFromDate);
    final isToDate = _isSameDate(date, _selectedToDate);
    final isSameDateSelection =
        isFromDate && isToDate && _selectedFromDate != null;
    final isInRange = _isDateInRange(date);

    // Determine colors and styling
    Color backgroundColor = Colors.transparent;
    Color textColor = isCurrentMonth ? AppColors.textPrimary : Colors.grey[300]!;
    FontWeight fontWeight = FontWeight.normal;
    BorderRadius? borderRadius;
    Border? border;
    Widget? label;

    if (isSameDateSelection) {
      backgroundColor = AppColors.primary;
      textColor = Colors.white;
      fontWeight = FontWeight.bold;
      borderRadius = BorderRadius.circular(AppDimensions.borderRadius);
    } else if (isFromDate) {
      backgroundColor = AppColors.primary;
      textColor = Colors.white;
      fontWeight = FontWeight.bold;
      borderRadius = BorderRadius.horizontal(
        left: Radius.circular(AppDimensions.borderRadius),
      );
      label = const Text(
        'From',
        style: TextStyle(color: Colors.white, fontSize: 8),
      );
    } else if (isToDate) {
      backgroundColor = AppColors.primary;
      textColor = Colors.white;
      fontWeight = FontWeight.bold;
      borderRadius = BorderRadius.horizontal(
        right: Radius.circular(AppDimensions.borderRadius),
      );
      label = const Text(
        'To',
        style: TextStyle(color: Colors.white, fontSize: 8),
      );
    } else if (isInRange) {
      backgroundColor = AppColors.primary.withValues(alpha: 0.15);
      textColor = AppColors.textPrimary;
    } else if (isToday && isCurrentMonth) {
      backgroundColor = AppColors.primary.withValues(alpha: 0.08);
      textColor = AppColors.primary;
      fontWeight = FontWeight.bold;
      border = Border.all(
        color: AppColors.primary.withValues(alpha: 0.5),
        width: 1.5,
      );
      borderRadius = BorderRadius.circular(AppDimensions.borderRadius);
    }

    return InkWell(
      onTap: isCurrentMonth ? () => _onDateTap(date) : null,
      borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.borderRadius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          border: border,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('d').format(date),
              style: TextStyle(
                color: textColor,
                fontWeight: fontWeight,
                fontSize: 14,
              ),
            ),
            if (label != null) ...[
              const SizedBox(height: 2),
              label,
            ] else
              const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedRangeDisplay() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.spacingM),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'From: ',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
              Text(
                _selectedFromDate != null
                    ? DateFormat('MMM d, yyyy').format(_selectedFromDate!)
                    : '--',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Icon(
            Icons.arrow_forward,
            size: 12,
            color: Colors.grey[400],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'To: ',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
              Text(
                _selectedToDate != null
                    ? DateFormat('MMM d, yyyy').format(_selectedToDate!)
                    : '--',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Cancel Button
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadius,
                    ),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            // Clear Button
            Expanded(
              child: OutlinedButton(
                onPressed: _clearSelection,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadius,
                    ),
                  ),
                ),
                child: const Text('Clear'),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            // Apply Button
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _selectedFromDate != null && _selectedToDate != null
                    ? _applySelection
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadius,
                    ),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildMonthNavigation(),
          _buildDaysOfWeekRow(),
          _buildCalendarGrid(),
          const SizedBox(height: AppDimensions.spacingS),
          _buildSelectedRangeDisplay(),
          _buildActionButtons(),
        ],
      ),
    );
  }
}
