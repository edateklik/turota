import 'package:turota_mobile/features/authentication/domain/models/auth_user.dart';
import 'package:turota_mobile/features/onboarding/taste_profile/data/dto/taste_profile_dto.dart';
import 'package:turota_mobile/features/onboarding/taste_profile/data/dto/update_taste_profile_request_dto.dart';

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
  Future<AuthUser> getCurrentUser();
  Future<TasteProfileDto> getTasteProfile();
  Future<TasteProfileDto> updateTasteProfile(UpdateTasteProfileRequestDto request);
}
