// Shared employee information model used across different features
class EmployeeInfoModel {
  final String id;
  final String firstName;
  final String lastName;

  EmployeeInfoModel({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  String get fullName => '$firstName $lastName';

  factory EmployeeInfoModel.fromJson(Map<String, dynamic> json) {
    return EmployeeInfoModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}
