import 'package:equatable/equatable.dart';
import '../../core/constants/enums.dart';
import 'customer.dart';
import 'service_line.dart';

class Appointment extends Equatable {
  final int id;
  final String appointmentNumber;
  final Customer customer;
  final List<ServiceLine> services;
  final DateTime scheduledTime;
  final DateTime? startTime;
  final DateTime? endTime;
  final AppointmentStatus status;
  final int assignedTechId;
  final String? notes;

  const Appointment({
    required this.id,
    required this.appointmentNumber,
    required this.customer,
    required this.services,
    required this.scheduledTime,
    this.startTime,
    this.endTime,
    required this.status,
    required this.assignedTechId,
    this.notes,
  });

  bool get isInProgress => status == AppointmentStatus.inProgress;
  bool get isCompleted => status == AppointmentStatus.completed;

  Duration? get duration {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    }
    return null;
  }

  @override
  List<Object?> get props => [id, appointmentNumber, scheduledTime, status];
}
