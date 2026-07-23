import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turota_mobile/core/widgets/current_user_avatar.dart';
import 'package:turota_mobile/features/authentication/domain/models/auth_user.dart';
import 'package:turota_mobile/features/authentication/presentation/providers/auth_providers.dart';
import 'package:turota_mobile/features/discover/presentation/widgets/category_header.dart';
import 'package:turota_mobile/features/profile/data/services/profile_photo_service.dart';
import 'package:turota_mobile/features/profile/domain/services/profile_photo_user_key_resolver.dart';
import 'package:turota_mobile/features/profile/presentation/controllers/profile_photo_controller.dart';

void main() {
  testWidgets('backend profil fotoğrafı URL kaynağını kullanır', (
    tester,
  ) async {
    await _pump(
      tester,
      child: const CurrentUserAvatar(),
      service: _FakeProfilePhotoService('/local/cache.jpg'),
      user: _user(
        firstName: 'Eda',
        profilePhotoUrl: 'https://example.com/avatar.jpg',
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is NetworkImage,
      ),
      findsOneWidget,
    );
  });

  testWidgets('kayıtlı profil fotoğrafını gösterir', (tester) async {
    await _pump(
      tester,
      child: const CurrentUserAvatar(),
      service: _FakeProfilePhotoService('/missing/profile_photo.jpg'),
      user: _user(firstName: 'Eda'),
    );

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('fotoğraf yoksa aynı kullanıcı baş harfini gösterir', (
    tester,
  ) async {
    await _pump(
      tester,
      child: const CurrentUserAvatar(),
      service: _FakeProfilePhotoService(null),
      user: _user(firstName: 'şule'),
    );

    expect(find.text('Ş'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsNothing);
  });

  testWidgets('kullanıcı bilgisi yoksa default kişi ikonu gösterir', (
    tester,
  ) async {
    await _pump(
      tester,
      child: const CurrentUserAvatar(),
      service: _FakeProfilePhotoService(null),
      user: _user(),
    );

    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.text('?'), findsNothing);
  });

  testWidgets('kategori header görselleri doğru eşleşir', (tester) async {
    const categories = [
      (
        CategoryImageAssets.gastronomy,
        Icons.restaurant_rounded,
        'Gastronomi kategorisi',
      ),
      (
        CategoryImageAssets.artCulture,
        Icons.museum_rounded,
        'Sanat ve kültür kategorisi',
      ),
      (
        CategoryImageAssets.cityLights,
        Icons.location_city_rounded,
        'Şehrin ışıkları kategorisi',
      ),
    ];
    for (final (asset, fallbackIcon, label) in categories) {
      await _pump(
        tester,
        child: Scaffold(
          appBar: CategoryHeader(
            title: label,
            subtitle: 'Kategori açıklaması',
            imageAsset: asset,
            fallbackIcon: fallbackIcon,
            imageSemanticLabel: label,
          ),
        ),
        service: _FakeProfilePhotoService(null),
        user: _user(firstName: 'Eda'),
      );

      final image = find.byKey(ValueKey(asset));
      expect(image, findsOneWidget);
      expect(
        tester.getSize(find.byKey(const ValueKey('category-header-image'))),
        const Size.square(48),
      );
      expect(find.byIcon(fallbackIcon), findsNothing);
    }
  });

  testWidgets('kategori görseli yüklenemezse küçük fallback gösterir', (
    tester,
  ) async {
    await _pump(
      tester,
      child: const Scaffold(
        appBar: CategoryHeader(
          title: 'Eksik kategori',
          subtitle: 'Kategori açıklaması',
          imageAsset: 'assets/images/categories/missing.jpg',
          fallbackIcon: Icons.image_not_supported_outlined,
          imageSemanticLabel: 'Eksik kategori görseli',
        ),
      ),
      service: _FakeProfilePhotoService(null),
      user: _user(firstName: 'Eda'),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('category-header-image-fallback')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('kategori header dark mode ve büyük metinde taşmaz', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pump(
      tester,
      themeMode: ThemeMode.dark,
      textScaler: const TextScaler.linear(1.8),
      child: const Scaffold(
        appBar: CategoryHeader(
          title: 'Sanat ve Kültür',
          subtitle: 'Şehrin kültürel zenginliklerini keşfet.',
          imageAsset: CategoryImageAssets.artCulture,
          fallbackIcon: Icons.museum_rounded,
          imageSemanticLabel: 'Sanat ve kültür kategorisi',
        ),
      ),
      service: _FakeProfilePhotoService(null),
      user: _user(firstName: 'Eda'),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('sanat Tümünü Gör satırı dar ekranda taşmaz', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pump(
      tester,
      textScaler: const TextScaler.linear(1.3),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: CategorySectionHeader(
            title: 'Yakınındaki Kültür Noktaları',
            actionLabel: 'Tümünü Gör',
            onAction: () {},
          ),
        ),
      ),
      service: _FakeProfilePhotoService(null),
      user: _user(firstName: 'Eda'),
    );
    expect(find.text('Tümünü Gör'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pump(
  WidgetTester tester, {
  required Widget child,
  required ProfilePhotoService service,
  required AuthUser user,
  ThemeMode themeMode = ThemeMode.light,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        profilePhotoServiceProvider.overrideWithValue(service),
        currentUserProvider.overrideWith((ref) async => user),
      ],
      child: MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: themeMode,
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: textScaler),
            child: child,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

AuthUser _user({
  String firstName = '',
  String lastName = '',
  String email = '',
  String? profilePhotoUrl,
}) {
  return AuthUser(
    id: 'test-user',
    email: email,
    firstName: firstName,
    lastName: lastName,
    role: 'User',
    profilePhotoUrl: profilePhotoUrl,
  );
}

class _FakeProfilePhotoService implements ProfilePhotoService {
  _FakeProfilePhotoService(this.path);

  String? path;

  @override
  Future<String?> load(ProfilePhotoUserKey userKey) async => path;

  @override
  Future<String?> pasteAndSave(ProfilePhotoUserKey userKey) async => null;

  @override
  Future<String?> recoverLostAndSave(ProfilePhotoUserKey userKey) async => null;

  @override
  Future<void> remove(ProfilePhotoUserKey userKey) async => path = null;

  @override
  Future<String?> recropAndSave(
    ProfilePhotoUserKey userKey,
    String currentPath,
  ) async => path;

  @override
  Future<String?> selectAndSave(
    ProfilePhotoUserKey userKey,
    ProfilePhotoSource source,
  ) async => null;
}
