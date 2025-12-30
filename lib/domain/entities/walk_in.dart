import 'package:equatable/equatable.dart';

enum WalkInStatus {
  waiting,
  inService,
}

class WalkIn extends Equatable {
  final String id;
  final String customerName;
  final String? customerPhone;
  final List<Map<String, dynamic>> services;
  final DateTime checkInTime;
  final WalkInStatus status;
  final String? assignedStation;
  final String? notes;

  const WalkIn({
    required this.id,
    required this.customerName,
    this.customerPhone,
    required this.services,
    required this.checkInTime,
    required this.status,
    this.assignedStation,
    this.notes,
  });

  WalkIn copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    List<Map<String, dynamic>>? services,
    DateTime? checkInTime,
    WalkInStatus? status,
    String? assignedStation,
    String? notes,
  }) {
    return WalkIn(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      services: services ?? this.services,
      checkInTime: checkInTime ?? this.checkInTime,
      status: status ?? this.status,
      assignedStation: assignedStation ?? this.assignedStation,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerName,
        customerPhone,
        services,
        checkInTime,
        status,
        assignedStation,
      ];
}
