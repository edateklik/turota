import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turota_mobile/core/theme/app_theme.dart';
import 'package:turota_mobile/features/authentication/domain/models/auth_user.dart';
import 'package:turota_mobile/features/authentication/presentation/providers/auth_providers.dart';
import 'package:turota_mobile/features/profile/data/services/profile_photo_service.dart';
import 'package:turota_mobile/features/profile/domain/services/profile_photo_user_key_resolver.dart';
import 'package:turota_mobile/features/profile/presentation/controllers/profile_photo_controller.dart';
import 'package:turota_mobile/features/profile/presentation/pages/edit_profile_page.dart';

void main() {
  testWidgets('fotoğraf yokken varsayılan profil ikonu görünür', (
    tester,
  ) async {
    await _pumpPage(tester, _FakeService());

    expect(
      find.byKey(const ValueKey('profile-photo-placeholder')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('profile-photo-image')), findsNothing);
  });

  testWidgets('kayıtlı fotoğraf varsa profil görseli oluşturulur', (
    tester,
  ) async {
    await _pumpPage(tester, _FakeService(photoPath: '/missing/test.jpg'));

    expect(find.byKey(const ValueKey('profile-photo-image')), findsOneWidget);
  });

  testWidgets('fotoğraf kaldırılınca varsayılan ikona dönülür', (tester) async {
    await _pumpPage(tester, _FakeService(photoPath: '/missing/test.jpg'));
    await tester.tap(find.bySemanticsLabel('Profil fotoğrafını değiştir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fotoğrafı Kaldır'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('profile-photo-placeholder')),
      findsOneWidget,
    );
    expect(find.text('Profil fotoğrafı kaldırıldı.'), findsOneWidget);
  });

  testWidgets('servis hatası SnackBar mesajı gösterir', (tester) async {
    await _pumpPage(
      tester,
      _FakeService(failure: const ProfilePhotoFailure('Test fotoğraf hatası.')),
    );
    await tester.tap(find.bySemanticsLabel('Profil fotoğrafı ekle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Galeriden Seç'));
    await tester.pumpAndSettle();

    expect(find.text('Test fotoğraf hatası.'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('profile-photo-placeholder')),
      findsOneWidget,
    );
  });

  testWidgets('panoda görsel yoksa Türkçe SnackBar gösterir', (tester) async {
    await _pumpPage(
      tester,
      _FakeService(
        failure: const ProfilePhotoFailure(
          'Panoda kullanılabilir bir görsel bulunamadı.',
        ),
      ),
    );
    await tester.tap(find.bySemanticsLabel('Profil fotoğrafı ekle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Panodan Yapıştır'));
    await tester.pumpAndSettle();

    expect(
      find.text('Panoda kullanılabilir bir görsel bulunamadı.'),
      findsOneWidget,
    );
  });
}

Future<void> _pumpPage(WidgetTester tester, ProfilePhotoService service) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        profilePhotoServiceProvider.overrideWithValue(service),
        currentUserProvider.overrideWith((ref) async {
          return const AuthUser(
            id: 'test-user',
            email: 'test@example.com',
            firstName: 'Test',
            lastName: 'User',
            role: 'User',
          );
        }),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const EditProfilePage()),
    ),
  );
  await tester.pump();
  await tester.pump();
}

class _FakeService implements ProfilePhotoService {
  _FakeService({this.photoPath, this.failure});

  String? photoPath;
  final ProfilePhotoFailure? failure;

  @override
  Future<String?> load(ProfilePhotoUserKey userKey) async => photoPath;

  @override
  Future<String?> pasteAndSave(ProfilePhotoUserKey userKey) async {
    if (failure != null) throw failure!;
    return null;
  }

  @override
  Future<String?> recoverLostAndSave(ProfilePhotoUserKey userKey) async => null;

  @override
  Future<void> remove(ProfilePhotoUserKey userKey) async => photoPath = null;

  @override
  Future<String?> recropAndSave(
    ProfilePhotoUserKey userKey,
    String currentPath,
  ) async => photoPath;

  @override
  Future<String?> selectAndSave(
    ProfilePhotoUserKey userKey,
    ProfilePhotoSource source,
  ) async {
    if (failure != null) throw failure!;
    return null;
  }
}
