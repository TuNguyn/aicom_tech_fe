import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/report_transaction_model.dart';
import '../../repositories/report_repository.dart';

class GetReportTransactions {
  final ReportRepository repository;

  GetReportTransactions(this.repository);

  Future<Either<Failure, ReportTransactionsResponse>> call({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int limit = 100,
  }) async {
    return await repository.getReportTransactions(
      startDate: startDate,
      endDate: endDate,
      page: page,
      limit: limit,
    );
  }
}
