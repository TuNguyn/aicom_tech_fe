import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/constants/enums.dart';
import '../entities/appointment.dart';

abstract class AppointmentRepository {
  Future<Either<Failure, List<Appointment>>> getTechAppointments(
    int techId,
    DateTime date,
  );

  Future<Either<Failure, Appointment>> getAppointmentDetails(int appointmentId);

  Future<Either<Failure, void>> updateAppointmentStatus(
    int appointmentId,
    AppointmentStatus status,
  );

  Future<Either<Failure, void>> startAppointment(int appointmentId);
  Future<Either<Failure, void>> completeAppointment(int appointmentId);
}
