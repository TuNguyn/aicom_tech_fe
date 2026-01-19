import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_data_source.dart';
import '../models/report_transaction_model.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  ReportRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, ReportTransactionsResponse>> getReportTransactions({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int limit = 100,
  }) async {
    try {
      final response = await remoteDataSource.getReportTransactions(
        startDate: startDate,
        endDate: endDate,
        page: page,
        limit: limit,
      );
      return Right(response);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure(
          'An unexpected error occurred while fetching reports: ${e.toString()}',
        ),
      );
    }
  }
}
