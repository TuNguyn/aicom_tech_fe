import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/report_transaction_model.dart';
import '../../domain/usecases/reports/get_report_transactions.dart';

class ReportsState {
  final Map<String, List<ReportTransactionModel>> transactionsByDateRange;
  final Map<String, ReportSummaryModel> summaryByDateRange;
  final AsyncValue<void> loadingStatus;

  ReportsState({
    this.transactionsByDateRange = const {},
    this.summaryByDateRange = const {},
    this.loadingStatus = const AsyncValue.data(null),
  });

  ReportsState copyWith({
    Map<String, List<ReportTransactionModel>>? transactionsByDateRange,
    Map<String, ReportSummaryModel>? summaryByDateRange,
    AsyncValue<void>? loadingStatus,
  }) {
    return ReportsState(
      transactionsByDateRange: transactionsByDateRange ?? this.transactionsByDateRange,
      summaryByDateRange: summaryByDateRange ?? this.summaryByDateRange,
      loadingStatus: loadingStatus ?? this.loadingStatus,
    );
  }

  /// Get transactions for a specific date range
  List<ReportTransactionModel> getTransactionsForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    final key = _getCacheKey(startDate, endDate);
    return transactionsByDateRange[key] ?? [];
  }

  /// Get summary for a specific date range
  ReportSummaryModel? getSummaryForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    final key = _getCacheKey(startDate, endDate);
    return summaryByDateRange[key];
  }

  /// Generate cache key from date range
  String _getCacheKey(DateTime startDate, DateTime endDate) {
    return '${startDate.year}-${startDate.month}-${startDate.day}_${endDate.year}-${endDate.month}-${endDate.day}';
  }
}

class ReportsNotifier extends StateNotifier<ReportsState> {
  final GetReportTransactions _getReportTransactions;

  ReportsNotifier(this._getReportTransactions) : super(ReportsState());

  /// Load reports for a specific date range
  Future<void> loadReportsForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Check cache first
    final key = state._getCacheKey(startDate, endDate);
    if (state.transactionsByDateRange.containsKey(key)) {
      // Data already in cache, no need to fetch
      return;
    }

    state = state.copyWith(loadingStatus: const AsyncValue.loading());

    final result = await _getReportTransactions(
      startDate: startDate,
      endDate: endDate,
      limit: 100, // Get all for date range
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          loadingStatus: AsyncValue.error(failure.message, StackTrace.current),
        );
      },
      (response) {
        state = state.copyWith(
          transactionsByDateRange: {...state.transactionsByDateRange, key: response.data},
          summaryByDateRange: {...state.summaryByDateRange, key: response.summary},
          loadingStatus: const AsyncValue.data(null),
        );
      },
    );
  }
}
