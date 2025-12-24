import 'package:equatable/equatable.dart';

class TechUser extends Equatable {
  final int id;
  final String username;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? avatarUrl;
  final String token;
  final bool isActive;

  const TechUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.avatarUrl,
    required this.token,
    this.isActive = true,
  });

  static final empty = TechUser(
    id: -1,
    username: '',
    fullName: '',
    email: '',
    token: '',
    isActive: false,
  );

  bool get isAuthenticated => token.isNotEmpty && id > 0;

  @override
  List<Object?> get props => [id, username, email, token];
}
