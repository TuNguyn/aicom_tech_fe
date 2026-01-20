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
    super.email,
    super.ssn,
    super.address,
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
      email: json['email'] as String?,
      ssn: json['ssn'] as String?,
      address: json['address'] as String?,
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
      email: json['email'] as String?,
      ssn: json['ssn'] as String?,
      address: json['address'] as String?,
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
      'email': email,
      'ssn': ssn,
      'address': address,
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
      email: email,
      ssn: ssn,
      address: address,
      token: token,
      isActive: isActive,
    );
  }
}

extension TechUserModelExtension on TechUserModel {
  TechUserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarColorHex,
    String? avatarForeColorHex,
    String? avatarMode,
    String? image,
    String? jobTitle,
    String? storeId,
    String? storeName,
    String? email,
    String? ssn,
    String? address,
    String? token,
    bool? isActive,
  }) {
    return TechUserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      avatarColorHex: avatarColorHex ?? this.avatarColorHex,
      avatarForeColorHex: avatarForeColorHex ?? this.avatarForeColorHex,
      avatarMode: avatarMode ?? this.avatarMode,
      image: image ?? this.image,
      jobTitle: jobTitle ?? this.jobTitle,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      email: email ?? this.email,
      ssn: ssn ?? this.ssn,
      address: address ?? this.address,
      token: token ?? this.token,
      isActive: isActive ?? this.isActive,
    );
  }
}
