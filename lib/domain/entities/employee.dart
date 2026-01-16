import 'package:equatable/equatable.dart';

class Employee extends Equatable {
  final String employeeId;
  final String firstName;
  final String lastName;
  final String storeId;
  final String storeName;
  final String? avatar;

  const Employee({
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.storeId,
    required this.storeName,
    this.avatar,
  });

  String get fullName => '$firstName $lastName';

  static const empty = Employee(
    employeeId: '',
    firstName: '',
    lastName: '',
    storeId: '',
    storeName: '',
  );

  @override
  List<Object?> get props => [employeeId, firstName, lastName, storeId, storeName, avatar];
}
