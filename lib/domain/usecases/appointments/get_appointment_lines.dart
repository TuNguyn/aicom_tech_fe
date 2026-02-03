import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/appointment_line.dart';
import '../../repositories/appointment_lines_repository.dart';

class GetAppointmentLines {
  final AppointmentLinesRepository repository;

  GetAppointmentLines(this.repository);

  Future<Either<Failure, List<AppointmentLine>>> call({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int limit = 100, // Get all appointments for the date range
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
