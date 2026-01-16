import '../../domain/entities/employee.dart';

class EmployeeModel extends Employee {
  const EmployeeModel({
    required super.employeeId,
    required super.firstName,
    required super.lastName,
    required super.storeId,
    required super.storeName,
    super.avatar,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      employeeId: json['employeeId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      storeId: json['storeId'] as String,
      storeName: json['storeName'] as String,
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'firstName': firstName,
      'lastName': lastName,
      'storeId': storeId,
      'storeName': storeName,
      'avatar': avatar,
    };
  }

  Employee toEntity() {
    return Employee(
      employeeId: employeeId,
      firstName: firstName,
      lastName: lastName,
      storeId: storeId,
      storeName: storeName,
      avatar: avatar,
    );
  }
}
