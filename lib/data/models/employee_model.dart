import '../../domain/entities/employee.dart';

class EmployeeModel extends Employee {
  const EmployeeModel({
    required super.employeeId,
    required super.firstName,
    required super.lastName,
    required super.storeId,
    required super.storeName,
    super.avatar,
    super.avatarMode,
    super.avatarColorHex,
    super.avatarForeColorHex,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      employeeId: json['employeeId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      storeId: json['storeId'] as String,
      storeName: json['storeName'] as String,
      avatar: json['avatar'] as String?,
      avatarMode: json['avatarMode'] as String?,
      avatarColorHex: json['avatarColorHex'] as String?,
      avatarForeColorHex: json['avatarForeColorHex'] as String?,
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
      'avatarMode': avatarMode,
      'avatarColorHex': avatarColorHex,
      'avatarForeColorHex': avatarForeColorHex,
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
      avatarMode: avatarMode,
      avatarColorHex: avatarColorHex,
      avatarForeColorHex: avatarForeColorHex,
    );
  }
}
