import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/appointment_line.dart';
import '../../entities/paginated_result.dart'; // Import generic
import '../../repositories/appointment_lines_repository.dart';

class GetAppointmentLines {
  final AppointmentLinesRepository repository;

  GetAppointmentLines(this.repository);

  // [SỬA] Đổi kiểu trả về thành PaginatedResult
  Future<Either<Failure, PaginatedResult<AppointmentLine>>> call({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int limit = 20,
    String sortBy = 'beginTime:ASC',
  }) async {
    return await repository.getAppointmentLines(
      startDate: startDate,
      endDate: endDate,
      page: page,
      limit: limit,
      sortBy: sortBy,
    );
  }
}
