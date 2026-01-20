// Shared customer information model used across different features
// Includes phone field which is required for UI compatibility
class CustomerInfoModel {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;

  CustomerInfoModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });

  String get fullName => '$firstName $lastName';

  factory CustomerInfoModel.fromJson(Map<String, dynamic> json) {
    return CustomerInfoModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String? ?? '', // Default to empty string if not present
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
    };
  }
}
