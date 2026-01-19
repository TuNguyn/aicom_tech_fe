import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../data/models/appointment_line_model.dart';

abstract class AppointmentLinesRepository {
  Future<Either<Failure, AppointmentLinesResponse>> getAppointmentLines({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int limit = 10,
    String sortBy = 'beginTime:ASC',
  });
}
