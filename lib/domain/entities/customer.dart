import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final int id;
  final String fullName;
  final String? phoneNumber;
  final String? email;
  final String? notes;
  final DateTime? lastVisit;
  final int totalVisits;

  const Customer({
    required this.id,
    required this.fullName,
    this.phoneNumber,
    this.email,
    this.notes,
    this.lastVisit,
    this.totalVisits = 0,
  });

  @override
  List<Object?> get props => [id, fullName, phoneNumber];
}
