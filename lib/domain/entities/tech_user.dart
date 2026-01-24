import 'package:equatable/equatable.dart';
import '../../config/app_config.dart';

class TechUser extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? avatarColorHex;
  final String? avatarForeColorHex;
  final String? avatarMode;
  final String? image;
  final String? jobTitle;
  final String? storeId;
  final String? storeName;
  final String? email;
  final String? ssn;
  final String? address;
  final String token;
  final bool isActive;

  const TechUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.avatarColorHex,
    this.avatarForeColorHex,
    this.avatarMode,
    this.image,
    this.jobTitle,
    this.storeId,
    this.storeName,
    this.email,
    this.ssn,
    this.address,
    required this.token,
    this.isActive = true,
  });

  String get fullName => '$firstName $lastName';

  /// Returns the full avatar URL by combining base URL with relative path
  /// If image is null or already a full URL, returns it as-is
  String? get avatarUrl {
    if (image == null || image!.isEmpty) {
      return null;
    }

    // If already a full URL (starts with http:// or https://), return as-is
    if (image!.startsWith('http://') || image!.startsWith('https://')) {
      return image;
    }

    // If relative path (starts with /), prepend base URL
    if (image!.startsWith('/')) {
      return '${AppConfig.baseUrl}$image';
    }

    // Otherwise return as-is
    return image;
  }

  static const empty = TechUser(
    id: '',
    firstName: '',
    lastName: '',
    token: '',
    isActive: false,
  );

  bool get isAuthenticated => token.isNotEmpty && id.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    phone,
    avatarColorHex,
    avatarForeColorHex,
    avatarMode,
    image,
    jobTitle,
    storeId,
    storeName,
    email,
    ssn,
    address,
    token,
    isActive,
  ];
}
