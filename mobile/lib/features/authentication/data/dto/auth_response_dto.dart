import 'package:turota_mobile/features/authentication/domain/models/auth_user.dart';

class AuthResponseDto {
  const AuthResponseDto({
    required this.accessToken,
    required this.tokenType,
    required this.expiresAt,
    required this.user,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      accessToken: json['accessToken'] as String,
      tokenType: json['tokenType'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      user: UserResponseDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  final String accessToken;
  final String tokenType;
  final DateTime expiresAt;
  final UserResponseDto user;
}

class UserResponseDto {
  const UserResponseDto({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.createdAt,
  });

  factory UserResponseDto.fromJson(Map<String, dynamic> json) {
    return UserResponseDto(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final DateTime createdAt;

  AuthUser toDomain() {
    return AuthUser(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: role,
    );
  }
}
