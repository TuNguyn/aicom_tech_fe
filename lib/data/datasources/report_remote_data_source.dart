import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/report_transaction_model.dart';

abstract class ReportRemoteDataSource {
  Future<ReportTransactionsResponse> getReportTransactions({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int limit = 100,
  });
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final DioClient dioClient;

  ReportRemoteDataSourceImpl(this.dioClient);

  @override
  Future<ReportTransactionsResponse> getReportTransactions({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int limit = 100,
  }) async {
    try {
      // Convert DateTime to YYYY-MM-DD format
      final startDateStr = startDate.toIso8601String().split('T')[0];
      final endDateStr = endDate.toIso8601String().split('T')[0];

      final response = await dioClient.get(
        '/employee-app/reports',
        queryParameters: {
          'page': page,
          'limit': limit,
          'startDate': startDateStr,
          'endDate': endDateStr,
        },
      );

      return ReportTransactionsResponse.fromJson(response.data as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'An unknown error occurred while fetching reports: $e',
      );
    }
  }
}
