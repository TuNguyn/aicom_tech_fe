import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/appointment_line.dart';
import '../../../../domain/entities/paginated_result.dart';
import '../../../../domain/repositories/appointment_lines_repository.dart';
import '../models/appointment_line_model.dart';
import '../models/paginated_response_model.dart';

class AppointmentLinesRepositoryImpl implements AppointmentLinesRepository {
  final Dio dio;

  AppointmentLinesRepositoryImpl(this.dio);

  @override
  Future<Either<Failure, PaginatedResult<AppointmentLine>>>
  getAppointmentLines({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int limit = 20,
    String sortBy = 'beginTime:ASC',
  }) async {
    try {
      // [FIX LỖI 500] Format ngày về dạng 'yyyy-MM-dd'
      // Server không nhận dạng ISO đầy đủ (có giờ phút giây)
      final dateFormat = DateFormat('yyyy-MM-dd');
      final startStr = dateFormat.format(startDate);
      final endStr = dateFormat.format(endDate);

      final response = await dio.get(
        '/employee-app/appointments/lines',
        queryParameters: {
          'startDate':
              startStr, // Gửi "2026-02-03" thay vì "2026-02-03T00:00..."
          'endDate': endStr,
          'page': page,
          'limit': limit,
          'sortBy': sortBy,
        },
      );

      final paginatedModel =
          PaginatedResponseModel<AppointmentLineModel>.fromJson(
            response.data,
            (json) => AppointmentLineModel.fromJson(json),
          );

      final resultEntity = paginatedModel.toEntity<AppointmentLine>(
        (modelItem) => modelItem.toEntity(),
      );

      return Right(resultEntity);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
