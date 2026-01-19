import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../data/models/report_transaction_model.dart';

abstract class ReportRepository {
  Future<Either<Failure, ReportTransactionsResponse>> getReportTransactions({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int limit = 100,
  });
}
