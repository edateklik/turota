import 'package:turota_mobile/features/authentication/domain/models/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser> login({required String email, required String password});
  Future<AuthUser> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });
  Future<void> logout();
  Future<String?> getStoredToken();
}
