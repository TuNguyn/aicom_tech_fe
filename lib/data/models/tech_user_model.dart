import '../../domain/entities/tech_user.dart';

class TechUserModel extends TechUser {
  const TechUserModel({
    required super.id,
    required super.username,
    required super.fullName,
    required super.email,
    super.phoneNumber,
    super.avatarUrl,
    required super.token,
    super.isActive,
  });

  factory TechUserModel.fromJson(Map<String, dynamic> json, String token) {
    return TechUserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      token: token,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
      'token': token,
      'is_active': isActive,
    };
  }

  TechUser toEntity() {
    return TechUser(
      id: id,
      username: username,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      avatarUrl: avatarUrl,
      token: token,
      isActive: isActive,
    );
  }
}
