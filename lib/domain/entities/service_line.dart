import 'package:equatable/equatable.dart';
import '../../core/constants/enums.dart';
import 'service.dart';

class ServiceLine extends Equatable {
  final int id;
  final Service service;
  final ServiceStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? notes;

  const ServiceLine({
    required this.id,
    required this.service,
    required this.status,
    this.startTime,
    this.endTime,
    this.notes,
  });

  bool get isInProgress => status == ServiceStatus.inProgress;
  bool get isCompleted => status == ServiceStatus.completed;

  @override
  List<Object?> get props => [id, service.id, status];
}
