class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.profilePhotoUrl,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? profilePhotoUrl;

  AuthUser copyWith({String? profilePhotoUrl, bool clearProfilePhoto = false}) {
    return AuthUser(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: role,
      profilePhotoUrl: clearProfilePhoto
          ? null
          : profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }
}
