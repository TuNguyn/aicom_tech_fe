import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/appointment_line.dart';

abstract class AppointmentLinesRepository {
  Future<Either<Failure, List<AppointmentLine>>> getAppointmentLines({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int limit = 10,
    String sortBy = 'beginTime:ASC',
  });
}
