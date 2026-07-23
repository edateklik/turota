import 'package:flutter_test/flutter_test.dart';
import 'package:turota_mobile/features/authentication/data/dto/auth_response_dto.dart';

void main() {
  test('login kullanıcı yanıtından profilePhotoUrl parse edilir', () {
    final dto = AuthResponseDto.fromJson({
      'accessToken': 'test-token',
      'tokenType': 'Bearer',
      'expiresAt': '2026-07-22T12:00:00Z',
      'user': {
        'id': 'stable-user-id',
        'email': 'eda@example.com',
        'firstName': 'Eda',
        'lastName': 'Teklik',
        'role': 'User',
        'createdAt': '2026-07-22T10:00:00Z',
        'profilePhotoUrl': '/uploads/profile-photos/avatar.jpg',
      },
    });

    expect(
      dto.user.toDomain().profilePhotoUrl,
      '/uploads/profile-photos/avatar.jpg',
    );
  });

  test('me yanıtında eksik profilePhotoUrl geriye uyumlu olarak null olur', () {
    final dto = UserResponseDto.fromJson({
      'id': 'stable-user-id',
      'email': 'eda@example.com',
      'firstName': 'Eda',
      'lastName': 'Teklik',
      'role': 'User',
      'createdAt': '2026-07-22T10:00:00Z',
    });

    expect(dto.toDomain().profilePhotoUrl, isNull);
  });
}
