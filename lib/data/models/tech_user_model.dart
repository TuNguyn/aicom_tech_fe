import '../../domain/entities/tech_user.dart';

class TechUserModel extends TechUser {
  const TechUserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    super.phone,
    super.avatarColorHex,
    super.avatarForeColorHex,
    super.avatarMode,
    super.image,
    super.jobTitle,
    super.storeId,
    super.storeName,
    required super.token,
    super.isActive,
  });

  factory TechUserModel.fromLoginResponse(Map<String, dynamic> json, String token) {
    final store = json['store'] as Map<String, dynamic>?;
    final status = json['status'] as String?;

    return TechUserModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String?,
      avatarColorHex: json['avatarColorHex'] as String?,
      avatarForeColorHex: json['avatarForeColorHex'] as String?,
      avatarMode: json['avatarMode'] as String?,
      image: json['image'] as String?,
      jobTitle: json['jobTitle'] as String?,
      storeId: store?['id'] as String?,
      storeName: store?['name'] as String?,
      token: token,
      isActive: status == 'ACTIVE',
    );
  }

  factory TechUserModel.fromJson(Map<String, dynamic> json, String token) {
    return TechUserModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String?,
      avatarColorHex: json['avatarColorHex'] as String?,
      avatarForeColorHex: json['avatarForeColorHex'] as String?,
      avatarMode: json['avatarMode'] as String?,
      image: json['image'] as String?,
      jobTitle: json['jobTitle'] as String?,
      storeId: json['storeId'] as String?,
      storeName: json['storeName'] as String?,
      token: token,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'avatarColorHex': avatarColorHex,
      'avatarForeColorHex': avatarForeColorHex,
      'avatarMode': avatarMode,
      'image': image,
      'jobTitle': jobTitle,
      'storeId': storeId,
      'storeName': storeName,
      'token': token,
      'isActive': isActive,
    };
  }

  TechUser toEntity() {
    return TechUser(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      avatarColorHex: avatarColorHex,
      avatarForeColorHex: avatarForeColorHex,
      avatarMode: avatarMode,
      image: image,
      jobTitle: jobTitle,
      storeId: storeId,
      storeName: storeName,
      token: token,
      isActive: isActive,
    );
  }
}
