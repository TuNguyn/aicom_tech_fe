import 'package:aicom_tech_fe/domain/entities/paginated_result.dart';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/appointment_line.dart';

abstract class AppointmentLinesRepository {
  Future<Either<Failure, PaginatedResult<AppointmentLine>>>
  getAppointmentLines({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int limit = 20, // Default 20
    String sortBy = 'beginTime:ASC',
  });
}
