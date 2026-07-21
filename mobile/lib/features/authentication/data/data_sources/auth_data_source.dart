import 'package:turota_mobile/core/networking/api_client.dart';
import 'package:turota_mobile/features/authentication/data/dto/auth_response_dto.dart';
import 'package:turota_mobile/features/authentication/data/dto/login_request_dto.dart';
import 'package:turota_mobile/features/authentication/data/dto/register_request_dto.dart';

class AuthDataSource {
  const AuthDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthResponseDto> login(LoginRequestDto request) async {
    final response = await _apiClient.post(
      '/api/identity/login',
      body: request.toJson(),
    );
    return AuthResponseDto.fromJson(response as Map<String, dynamic>);
  }

  Future<AuthResponseDto> register(RegisterRequestDto request) async {
    final response = await _apiClient.post(
      '/api/identity/register',
      body: request.toJson(),
    );
    return AuthResponseDto.fromJson(response as Map<String, dynamic>);
  }

  Future<UserResponseDto> getCurrentUser() async {
    final response = await _apiClient.get('/api/identity/me');
    return UserResponseDto.fromJson(response as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getTasteProfile() async {
    final response = await _apiClient.get('/api/identity/me/taste-profile');
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateTasteProfile(Map<String, dynamic> request) async {
    final response = await _apiClient.put(
      '/api/identity/me/taste-profile',
      body: request,
    );
    return response as Map<String, dynamic>;
  }
}
