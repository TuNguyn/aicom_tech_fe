import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/appointment_line_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<AppointmentLinesResponse> getAppointmentLines({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int limit = 10,
    String sortBy = 'beginTime:ASC',
  });
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final DioClient dioClient;

  AppointmentRemoteDataSourceImpl(this.dioClient);

  @override
  Future<AppointmentLinesResponse> getAppointmentLines({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int limit = 10,
    String sortBy = 'beginTime:ASC',
  }) async {
    try {
      final response = await dioClient.get(
        '/employee-app/appointments/lines',
        queryParameters: {
          'page': page,
          'limit': limit,
          'sortBy': sortBy,
          'startDate': startDate.toIso8601String().split('T')[0], // YYYY-MM-DD
          'endDate': endDate.toIso8601String().split('T')[0], // YYYY-MM-DD
        },
      );

      return AppointmentLinesResponse.fromJson(response.data as Map<String, dynamic>);
    } on AuthException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'An unknown error occurred while fetching appointments: $e',
      );
    }
  }
}
