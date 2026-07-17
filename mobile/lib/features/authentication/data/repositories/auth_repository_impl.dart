import 'package:turota_mobile/core/storage/token_storage.dart';
import 'package:turota_mobile/features/authentication/data/data_sources/auth_data_source.dart';
import 'package:turota_mobile/features/authentication/data/dto/login_request_dto.dart';
import 'package:turota_mobile/features/authentication/data/dto/register_request_dto.dart';
import 'package:turota_mobile/features/authentication/domain/models/auth_user.dart';
import 'package:turota_mobile/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource, this._tokenStorage);

  final AuthDataSource _dataSource;
  final TokenStorage _tokenStorage;

  @override
  Future<AuthUser> login({required String email, required String password}) async {
    final dto = LoginRequestDto(email: email, password: password);
    final response = await _dataSource.login(dto);

    await _tokenStorage.saveToken(response.accessToken);
    return response.user.toDomain();
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final dto = RegisterRequestDto(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
    final response = await _dataSource.register(dto);

    await _tokenStorage.saveToken(response.accessToken);
    return response.user.toDomain();
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.deleteToken();
  }

  @override
  Future<String?> getStoredToken() async {
    return _tokenStorage.getToken();
  }
}
