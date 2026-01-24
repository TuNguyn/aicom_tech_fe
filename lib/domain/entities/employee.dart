import 'package:equatable/equatable.dart';
import '../../config/app_config.dart';

class Employee extends Equatable {
  final String employeeId;
  final String firstName;
  final String lastName;
  final String storeId;
  final String storeName;
  final String? avatar;
  final String? avatarMode;
  final String? avatarColorHex;
  final String? avatarForeColorHex;

  const Employee({
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.storeId,
    required this.storeName,
    this.avatar,
    this.avatarMode,
    this.avatarColorHex,
    this.avatarForeColorHex,
  });

  String get fullName => '$firstName $lastName';

  /// Returns the full avatar URL by combining base URL with relative path
  /// If avatar is null or already a full URL, returns it as-is
  String? get avatarUrl {
    if (avatar == null || avatar!.isEmpty) {
      return null;
    }

    // If already a full URL (starts with http:// or https://), return as-is
    if (avatar!.startsWith('http://') || avatar!.startsWith('https://')) {
      return avatar;
    }

    // If relative path (starts with /), prepend base URL
    if (avatar!.startsWith('/')) {
      return '${AppConfig.baseUrl}$avatar';
    }

    // Otherwise return as-is
    return avatar;
  }

  static const empty = Employee(
    employeeId: '',
    firstName: '',
    lastName: '',
    storeId: '',
    storeName: '',
  );

  @override
  List<Object?> get props => [
    employeeId,
    firstName,
    lastName,
    storeId,
    storeName,
    avatar,
    avatarMode,
    avatarColorHex,
    avatarForeColorHex,
  ];
}
