import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turota_mobile/app/app.dart';
import 'package:turota_mobile/app/router/app_router.dart';
import 'package:turota_mobile/core/constants/app_constants.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_theme.dart';
import 'package:turota_mobile/features/authentication/domain/models/auth_user.dart';
import 'package:turota_mobile/features/authentication/domain/repositories/auth_repository.dart';
import 'package:turota_mobile/features/authentication/presentation/pages/login_page.dart';
import 'package:turota_mobile/features/authentication/presentation/pages/register_page.dart';
import 'package:turota_mobile/features/authentication/presentation/providers/auth_providers.dart';
import 'package:turota_mobile/features/discover/presentation/pages/discover_page.dart';
import 'package:turota_mobile/features/onboarding/location/presentation/pages/location_permission_page.dart';
import 'package:turota_mobile/features/saved/presentation/pages/saved_page.dart';
import 'package:turota_mobile/features/splash/presentation/pages/splash_page.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<String?> getStoredToken() async => 'test-token';

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    return AuthUser(
      id: 'test-user',
      email: email,
      firstName: 'Şevval',
      lastName: 'Test',
      role: 'User',
    );
  }

  @override
  Future<void> logout() async {}

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    return AuthUser(
      id: 'test-user',
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: 'User',
    );
  }
}

void main() {
  Widget withTestProviders(Widget child) {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
      ],
      child: child,
    );
  }

  Future<void> pumpToLocationPermission(WidgetTester tester) async {
    await tester.pumpWidget(withTestProviders(const TurotaApp()));
    await tester.pump(AppConstants.splashDisplayDuration);
    await tester.pumpAndSettle();
  }

  Future<void> tapLocationActionAndExpectLogin(
    WidgetTester tester,
    String label,
  ) async {
    await pumpToLocationPermission(tester);
    await tester.ensureVisible(find.text(label));
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  }

  Future<void> pumpLoginPage(WidgetTester tester) async {
    await tester.pumpWidget(
      withTestProviders(
        MaterialApp(
          theme: AppTheme.light,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: const LoginPage(),
        ),
      ),
    );
  }

  Future<void> pumpRegisterPage(WidgetTester tester) async {
    await tester.pumpWidget(
      withTestProviders(
        MaterialApp(
          theme: AppTheme.light,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: const RegisterPage(),
        ),
      ),
    );
  }

  Future<void> pumpDiscoverPage(WidgetTester tester) async {
    await tester.pumpWidget(
      withTestProviders(
        MaterialApp(
          theme: AppTheme.light,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: const DiscoverPage(),
        ),
      ),
    );
  }

  Future<void> pumpSavedPage(WidgetTester tester) async {
    await tester.pumpWidget(
      withTestProviders(
        MaterialApp(
          theme: AppTheme.light,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: const SavedPage(),
        ),
      ),
    );
  }

  Future<void> openRegisterFromLogin(WidgetTester tester) async {
    await pumpLoginPage(tester);
    await tester.tap(find.text('Kayıt Ol'));
    await tester.pumpAndSettle();
  }

  Future<void> fillRegistration(
    WidgetTester tester, {
    String name = 'Ada Yılmaz',
    String email = 'ada@example.com',
    String password = 'guvenli123',
    String confirmPassword = 'guvenli123',
    bool acceptTerms = true,
  }) async {
    await tester.enterText(
      find.byKey(const ValueKey('register-name-field')),
      name,
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-email-field')),
      email,
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-password-field')),
      password,
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-confirm-password-field')),
      confirmPassword,
    );
    if (acceptTerms) {
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
    }
  }

  Future<void> submitRegistration(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(const ValueKey('register-submit')));
    await tester.tap(find.byKey(const ValueKey('register-submit')));
    await tester.pump();
  }

  EditableText editableField(WidgetTester tester, String key) {
    return tester.widget(
      find.descendant(
        of: find.byKey(ValueKey(key)),
        matching: find.byType(EditableText),
      ),
    );
  }

  testWidgets('SplashPage is shown first', (tester) async {
    await tester.pumpWidget(withTestProviders(const TurotaApp()));

    expect(find.byType(SplashPage), findsOneWidget);

    await tester.pump(AppConstants.splashDisplayDuration);
    await tester.pumpAndSettle();
  });

  testWidgets('SplashPage contains the local logo asset', (tester) async {
    await tester.pumpWidget(withTestProviders(const TurotaApp()));

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<AssetImage>());
    expect((image.image as AssetImage).assetName, AppConstants.logoAssetPath);

    await tester.pump(AppConstants.splashDisplayDuration);
    await tester.pumpAndSettle();
  });

  testWidgets('SplashPage uses the branded background', (tester) async {
    await tester.pumpWidget(withTestProviders(const TurotaApp()));

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppColors.splashBackground);

    await tester.pump(AppConstants.splashDisplayDuration);
    await tester.pumpAndSettle();
  });

  testWidgets('location permission page follows the splash', (tester) async {
    await pumpToLocationPermission(tester);

    expect(find.byType(SplashPage), findsNothing);
    expect(find.byType(LocationPermissionPage), findsOneWidget);
  });

  testWidgets('location permission content and actions are present', (
    tester,
  ) async {
    await pumpToLocationPermission(tester);

    expect(find.text('Konumunuzu etkinleştirin'), findsOneWidget);
    expect(
      find.text(
        'Size özel mahalle ve mekan önerileri alabilmek için konum '
        'erişimine izin verin.',
      ),
      findsOneWidget,
    );
    expect(find.text('Konuma İzin Ver'), findsOneWidget);
    expect(find.text('Şehri Manuel Seç'), findsOneWidget);
    expect(find.text('Belki daha sonra'), findsOneWidget);
  });

  testWidgets('primary location action opens login', (tester) async {
    await tapLocationActionAndExpectLogin(tester, 'Konuma İzin Ver');
  });

  testWidgets('manual city action opens login', (tester) async {
    await tapLocationActionAndExpectLogin(tester, 'Şehri Manuel Seç');
  });

  testWidgets('later action opens login', (tester) async {
    await tapLocationActionAndExpectLogin(tester, 'Belki daha sonra');
  });

  testWidgets('location permission page does not overflow on a small phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpToLocationPermission(tester);

    expect(find.byType(LocationPermissionPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('LoginPage renders the login experience', (tester) async {
    await pumpLoginPage(tester);

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('TUROTA'), findsOneWidget);
    expect(find.text('Bir sonraki maceranı keşfet.'), findsOneWidget);
    expect(find.byKey(const ValueKey('email-field')), findsOneWidget);
    expect(find.byKey(const ValueKey('password-field')), findsOneWidget);
    expect(find.text('Google ile devam et'), findsOneWidget);
  });

  testWidgets('login mode is visually active', (tester) async {
    await pumpLoginPage(tester);

    final indicator = tester.widget<Container>(
      find.byKey(const ValueKey('login-active-indicator')),
    );
    final decoration = indicator.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.primary);
  });

  testWidgets('LoginPage registration action opens RegisterPage', (
    tester,
  ) async {
    await openRegisterFromLogin(tester);

    expect(find.byType(RegisterPage), findsOneWidget);
  });

  testWidgets('password visibility toggles', (tester) async {
    await pumpLoginPage(tester);

    EditableText passwordField = tester.widget(
      find.descendant(
        of: find.byKey(const ValueKey('password-field')),
        matching: find.byType(EditableText),
      ),
    );
    expect(passwordField.obscureText, isTrue);

    await tester.tap(find.byKey(const ValueKey('password-visibility-toggle')));
    await tester.pump();

    passwordField = tester.widget(
      find.descendant(
        of: find.byKey(const ValueKey('password-field')),
        matching: find.byType(EditableText),
      ),
    );
    expect(passwordField.obscureText, isFalse);
  });

  testWidgets('invalid login shows Turkish validation errors', (tester) async {
    await pumpLoginPage(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('login-submit')));
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pump();

    expect(find.text('E-posta adresinizi girin.'), findsOneWidget);
    expect(find.text('Şifrenizi girin.'), findsOneWidget);
  });

  testWidgets('valid temporary login opens DiscoverPage', (tester) async {
    await pumpLoginPage(tester);
    await tester.enterText(
      find.byKey(const ValueKey('email-field')),
      'merhaba@ornek.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('password-field')),
      'guvenli-sifre',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('login-submit')));
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();

    expect(find.byType(DiscoverPage), findsOneWidget);
  });

  testWidgets('forgot-password action shows its SnackBar', (tester) async {
    await pumpLoginPage(tester);
    await tester.ensureVisible(find.text('Unuttum?'));
    await tester.tap(find.text('Unuttum?'));
    await tester.pump();

    expect(
      find.text('Şifre yenileme akışı yakında eklenecek.'),
      findsOneWidget,
    );
  });

  testWidgets('Google action shows its SnackBar', (tester) async {
    await pumpLoginPage(tester);
    await tester.ensureVisible(find.text('Google ile devam et'));
    await tester.tap(find.text('Google ile devam et'));
    await tester.pump();

    expect(find.text('Google ile giriş yakında eklenecek.'), findsOneWidget);
  });

  testWidgets('LoginPage does not overflow on a small phone', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpLoginPage(tester);

    expect(find.byType(LoginPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('RegisterPage renders all fields and header content', (
    tester,
  ) async {
    await pumpRegisterPage(tester);

    expect(find.text("TUROTA'ya Katıl"), findsOneWidget);
    expect(
      find.text('Hesabını oluştur ve sana özel mekanları keşfetmeye başla.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('register-name-field')), findsOneWidget);
    expect(find.byKey(const ValueKey('register-email-field')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('register-password-field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('register-confirm-password-field')),
      findsOneWidget,
    );
  });

  testWidgets('registration password visibility toggles independently', (
    tester,
  ) async {
    await pumpRegisterPage(tester);

    expect(
      editableField(tester, 'register-password-field').obscureText,
      isTrue,
    );
    expect(
      editableField(tester, 'register-confirm-password-field').obscureText,
      isTrue,
    );

    await tester.tap(find.byKey(const ValueKey('register-password-toggle')));
    await tester.pump();

    expect(
      editableField(tester, 'register-password-field').obscureText,
      isFalse,
    );
    expect(
      editableField(tester, 'register-confirm-password-field').obscureText,
      isTrue,
    );

    await tester.tap(
      find.byKey(const ValueKey('register-confirm-password-toggle')),
    );
    await tester.pump();

    expect(
      editableField(tester, 'register-password-field').obscureText,
      isFalse,
    );
    expect(
      editableField(tester, 'register-confirm-password-field').obscureText,
      isFalse,
    );
  });

  testWidgets('empty registration shows Turkish validation errors', (
    tester,
  ) async {
    await pumpRegisterPage(tester);
    await submitRegistration(tester);

    expect(find.text('Ad soyad alanı zorunludur.'), findsOneWidget);
    expect(find.text('E-posta adresi zorunludur.'), findsOneWidget);
    expect(find.text('Şifre alanı zorunludur.'), findsOneWidget);
    expect(find.text('Şifre onayı zorunludur.'), findsOneWidget);
    expect(
      find.text('Devam etmek için şartları kabul etmelisiniz.'),
      findsOneWidget,
    );
    expect(find.byType(RegisterPage), findsOneWidget);
  });

  testWidgets('invalid registration email shows validation error', (
    tester,
  ) async {
    await pumpRegisterPage(tester);
    await fillRegistration(tester, email: 'gecersiz-eposta');
    await submitRegistration(tester);

    expect(find.text('Geçerli bir e-posta adresi girin.'), findsOneWidget);
    expect(find.byType(RegisterPage), findsOneWidget);
  });

  testWidgets('short registration password shows validation error', (
    tester,
  ) async {
    await pumpRegisterPage(tester);
    await fillRegistration(tester, password: 'kisa', confirmPassword: 'kisa');
    await submitRegistration(tester);

    expect(find.text('Şifre en az 8 karakter olmalıdır.'), findsOneWidget);
    expect(find.byType(RegisterPage), findsOneWidget);
  });

  testWidgets('non-matching registration passwords show validation error', (
    tester,
  ) async {
    await pumpRegisterPage(tester);
    await fillRegistration(tester, confirmPassword: 'baska-sifre');
    await submitRegistration(tester);

    expect(find.text('Şifreler eşleşmiyor.'), findsOneWidget);
    expect(find.byType(RegisterPage), findsOneWidget);
  });

  testWidgets('unaccepted terms prevent registration', (tester) async {
    await pumpRegisterPage(tester);
    await fillRegistration(tester, acceptTerms: false);
    await submitRegistration(tester);

    expect(
      find.text('Devam etmek için şartları kabul etmelisiniz.'),
      findsOneWidget,
    );
    expect(find.byType(RegisterPage), findsOneWidget);
  });

  testWidgets('valid temporary registration opens DiscoverPage', (
    tester,
  ) async {
    await pumpRegisterPage(tester);
    await fillRegistration(tester);
    await submitRegistration(tester);
    await tester.pumpAndSettle();

    expect(find.byType(DiscoverPage), findsOneWidget);
  });

  testWidgets('registration Google action shows its SnackBar', (tester) async {
    await pumpRegisterPage(tester);
    await tester.ensureVisible(find.text('Google ile devam et'));
    await tester.tap(find.text('Google ile devam et'));
    await tester.pump();

    expect(find.text('Google ile kayıt yakında eklenecek.'), findsOneWidget);
  });

  testWidgets('registration terms action shows its SnackBar', (tester) async {
    await pumpRegisterPage(tester);
    await tester.ensureVisible(find.text('Kullanım Şartları'));
    await tester.tap(find.text('Kullanım Şartları'));
    await tester.pump();

    expect(find.text('Kullanım şartları yakında eklenecek.'), findsOneWidget);
  });

  testWidgets('registration privacy action shows its SnackBar', (tester) async {
    await pumpRegisterPage(tester);
    await tester.ensureVisible(find.text('Gizlilik Politikası'));
    await tester.tap(find.text('Gizlilik Politikası'));
    await tester.pump();

    expect(find.text('Gizlilik politikası yakında eklenecek.'), findsOneWidget);
  });

  testWidgets('registration back button returns to LoginPage', (tester) async {
    await openRegisterFromLogin(tester);
    await tester.tap(find.byKey(const ValueKey('register-back')));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(RegisterPage), findsNothing);
  });

  testWidgets('registration bottom login action returns to LoginPage', (
    tester,
  ) async {
    await openRegisterFromLogin(tester);
    await tester.ensureVisible(
      find.byKey(const ValueKey('register-login-action')),
    );
    await tester.tap(find.byKey(const ValueKey('register-login-action')));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(RegisterPage), findsNothing);
  });

  testWidgets('RegisterPage does not overflow on a small phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpRegisterPage(tester);

    expect(find.byType(RegisterPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('DiscoverPage shows the sample greeting and date', (
    tester,
  ) async {
    await pumpDiscoverPage(tester);

    expect(find.text('Günaydın, Şevval'), findsOneWidget);
    expect(find.text('12 Ekim Cumartesi'), findsOneWidget);
  });

  testWidgets('DiscoverPage renders the weather sample cards', (tester) async {
    await pumpDiscoverPage(tester);

    expect(find.text('7 Günlük Hava Durumu'), findsOneWidget);
    for (final day in ['Bugün', 'Paz', 'Pzt', 'Sal', 'Çar']) {
      expect(find.byKey(ValueKey('weather-$day')), findsOneWidget);
    }
    for (final temperature in ['24°', '22°', '19°', '17°', '20°']) {
      expect(find.text(temperature), findsOneWidget);
    }
  });

  testWidgets('DiscoverPage renders current location preview', (tester) async {
    await pumpDiscoverPage(tester);

    expect(find.text('Mevcut Konumunuz'), findsOneWidget);
    expect(find.byKey(const ValueKey('full-map-button')), findsOneWidget);
  });

  testWidgets('full map action shows temporary feedback', (tester) async {
    await pumpDiscoverPage(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('full-map-button')));
    await tester.tap(find.byKey(const ValueKey('full-map-button')));
    await tester.pump();

    expect(find.text('Tam harita ekranı yakında eklenecek.'), findsOneWidget);
  });

  testWidgets('DiscoverPage renders all category cards', (tester) async {
    await pumpDiscoverPage(tester);

    for (final category in [
      'Gastronomi',
      'Sanat ve Kültür',
      'Gece Hayatı ve Etkinlik',
    ]) {
      expect(find.byKey(ValueKey('category-$category')), findsOneWidget);
      expect(find.text(category), findsOneWidget);
    }
  });

  testWidgets('category action shows category-specific feedback', (
    tester,
  ) async {
    await pumpDiscoverPage(tester);
    final category = find.byKey(const ValueKey('category-Gastronomi'));
    await tester.ensureVisible(category);
    await tester.tap(category);
    await tester.pump();

    expect(
      find.text('Gastronomi kategorisi yakında açılacak.'),
      findsOneWidget,
    );
  });

  testWidgets('DiscoverPage renders all nearby places', (tester) async {
    await pumpDiscoverPage(tester);

    expect(find.text('Yakınındaki Mekanlar'), findsOneWidget);
    for (final place in ['Balat', 'Nişantaşı', 'Moda, Kadıköy']) {
      expect(find.byKey(ValueKey('place-$place')), findsOneWidget);
      expect(find.text(place), findsOneWidget);
    }
  });

  testWidgets('see-all places action shows temporary feedback', (tester) async {
    await pumpDiscoverPage(tester);
    final action = find.byKey(const ValueKey('see-all-places'));
    await tester.ensureVisible(action);
    await tester.tap(action);
    await tester.pump();

    expect(find.text('Tüm mekanlar ekranı yakında eklenecek.'), findsOneWidget);
  });

  testWidgets('notification action shows temporary feedback', (tester) async {
    await pumpDiscoverPage(tester);
    await tester.tap(find.byKey(const ValueKey('discover-notifications')));
    await tester.pump();

    expect(find.text('Bildirimler yakında eklenecek.'), findsOneWidget);
  });

  testWidgets('DiscoverPage renders all bottom navigation destinations', (
    tester,
  ) async {
    await pumpDiscoverPage(tester);

    for (final label in ['Keşfet', 'Kaydedilenler', 'AI Asistan', 'Profil']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('inactive bottom navigation items show temporary feedback', (
    tester,
  ) async {
    await pumpDiscoverPage(tester);

    const expectations = {
      'AI Asistan': 'AI asistan ekranı yakında eklenecek.',
      'Profil': 'Profil ekranı yakında eklenecek.',
    };
    for (final entry in expectations.entries) {
      await tester.tap(find.text(entry.key));
      await tester.pump();
      expect(find.text(entry.value), findsOneWidget);
    }
  });

  testWidgets('DiscoverPage does not overflow on a small phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpDiscoverPage(tester);
    await tester.pump(const Duration(milliseconds: 950));

    expect(find.byType(DiscoverPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('weather strip scrolls horizontally without layout errors', (
    tester,
  ) async {
    await pumpDiscoverPage(tester);
    final weatherStrip = find.byKey(
      const ValueKey('weather-horizontal-scroll'),
    );

    await tester.drag(weatherStrip, const Offset(-180, 0));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('weather-Çar')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Discover Kaydedilenler destination opens SavedPage', (
    tester,
  ) async {
    await pumpDiscoverPage(tester);
    await tester.tap(find.text('Kaydedilenler'));
    await tester.pumpAndSettle();

    expect(find.byType(SavedPage), findsOneWidget);
  });

  testWidgets('SavedPage title and initial places tab render', (tester) async {
    await pumpSavedPage(tester);

    expect(find.byKey(const ValueKey('saved-page-title')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('saved-active-tab-Mekanlar')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('saved-places-tab')), findsOneWidget);
  });

  testWidgets('SavedPage renders all collection names', (tester) async {
    await pumpSavedPage(tester);

    for (final collection in [
      'Hafta Sonu Kahvaltısı',
      'Sanat Rotası',
      'Gizli Cevherler',
      'Yeni Liste',
    ]) {
      expect(find.text(collection), findsOneWidget);
    }
  });

  testWidgets('normal collection shows temporary feedback', (tester) async {
    await pumpSavedPage(tester);
    final collection = find.byKey(
      const ValueKey('collection-Hafta Sonu Kahvaltısı'),
    );
    await tester.ensureVisible(collection);
    await tester.tap(collection);
    await tester.pump();

    expect(
      find.text('Hafta Sonu Kahvaltısı koleksiyonu yakında açılacak.'),
      findsOneWidget,
    );
  });

  testWidgets('new collection card shows temporary feedback', (tester) async {
    await pumpSavedPage(tester);
    final collection = find.byKey(const ValueKey('collection-Yeni Liste'));
    await tester.ensureVisible(collection);
    await tester.tap(collection);
    await tester.pump();

    expect(
      find.text('Yeni koleksiyon oluşturma yakında eklenecek.'),
      findsOneWidget,
    );
  });

  testWidgets('SavedPage renders places and match badges', (tester) async {
    await pumpSavedPage(tester);

    for (final place in [
      'Minoa Books & Coffee',
      'The Hearth Bakery',
      'Vantage Point Bar',
    ]) {
      expect(find.text(place), findsOneWidget);
    }
    for (final match in ['%94 Eşleşme', '%88 Eşleşme', '%91 Eşleşme']) {
      expect(find.text(match), findsOneWidget);
    }
  });

  testWidgets('saved place bookmarks toggle independently', (tester) async {
    await pumpSavedPage(tester);
    final minoaBookmark = find.byKey(const ValueKey('bookmark-minoa'));
    await tester.ensureVisible(minoaBookmark);

    IconButton minoaButton = tester.widget(minoaBookmark);
    IconButton hearthButton = tester.widget(
      find.byKey(const ValueKey('bookmark-hearth')),
    );
    expect((minoaButton.icon as Icon).icon, Icons.bookmark_rounded);
    expect((hearthButton.icon as Icon).icon, Icons.bookmark_rounded);

    await tester.tap(minoaBookmark);
    await tester.pump();

    minoaButton = tester.widget(minoaBookmark);
    hearthButton = tester.widget(find.byKey(const ValueKey('bookmark-hearth')));
    expect((minoaButton.icon as Icon).icon, Icons.bookmark_border_rounded);
    expect((hearthButton.icon as Icon).icon, Icons.bookmark_rounded);
    expect(
      find.text('Minoa Books & Coffee kaydedilenlerden çıkarıldı.'),
      findsOneWidget,
    );
    expect(
      find.text('Minoa Books & Coffee detay ekranı yakında eklenecek.'),
      findsNothing,
    );

    await tester.tap(minoaBookmark);
    await tester.pump();
    expect(
      find.text('Minoa Books & Coffee kaydedilenlere eklendi.'),
      findsOneWidget,
    );
  });

  testWidgets('saved place card shows detail feedback', (tester) async {
    await pumpSavedPage(tester);
    final place = find.byKey(const ValueKey('saved-place-minoa'));
    await tester.ensureVisible(place);
    await tester.tap(place);
    await tester.pump();

    expect(
      find.text('Minoa Books & Coffee detay ekranı yakında eklenecek.'),
      findsOneWidget,
    );
  });

  testWidgets('Planlar tab renders all saved plan cards', (tester) async {
    await pumpSavedPage(tester);
    await tester.tap(find.byKey(const ValueKey('saved-tab-Planlar')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('saved-plans-tab')), findsOneWidget);
    expect(find.text('Karaköy Sanat Turu'), findsOneWidget);
    expect(find.text('Boğaz Hattı Kahvaltısı'), findsOneWidget);
    expect(find.text('Eski Şehir Gizemleri'), findsOneWidget);
    expect(find.text('Yapay Zeka Rotası'), findsOneWidget);
    expect(find.text('Gurme Rotası'), findsOneWidget);
    expect(find.text('Tarih Turu'), findsOneWidget);
  });

  testWidgets('saved plan bookmark toggles and shows feedback', (tester) async {
    await pumpSavedPage(tester);
    await tester.tap(find.byKey(const ValueKey('saved-tab-Planlar')));
    await tester.pumpAndSettle();

    final bookmark = find.byKey(
      const ValueKey('saved-plan-bookmark-karakoy-art'),
    );
    await tester.ensureVisible(bookmark);

    IconButton button = tester.widget(bookmark);
    expect((button.icon as Icon).icon, Icons.bookmark_rounded);

    await tester.tap(bookmark);
    await tester.pump();

    button = tester.widget(bookmark);
    expect((button.icon as Icon).icon, Icons.bookmark_border_rounded);
    expect(
      find.text('Karaköy Sanat Turu kaydedilenlerden çıkarıldı.'),
      findsOneWidget,
    );
    expect(
      find.text('Karaköy Sanat Turu plan detayı yakında eklenecek.'),
      findsNothing,
    );

    await tester.tap(bookmark);
    await tester.pump();
    expect(
      find.text('Karaköy Sanat Turu kaydedilenlere eklendi.'),
      findsOneWidget,
    );
  });

  testWidgets('saved plan card shows detail feedback', (tester) async {
    await pumpSavedPage(tester);
    await tester.tap(find.byKey(const ValueKey('saved-tab-Planlar')));
    await tester.pumpAndSettle();

    final plan = find.byKey(const ValueKey('saved-plan-bosphorus-breakfast'));
    await tester.ensureVisible(plan);
    await tester.tap(plan);
    await tester.pump();

    expect(
      find.text('Boğaz Hattı Kahvaltısı plan detayı yakında eklenecek.'),
      findsOneWidget,
    );
  });

  testWidgets('switching back to Mekanlar restores saved places', (
    tester,
  ) async {
    await pumpSavedPage(tester);
    await tester.tap(find.byKey(const ValueKey('saved-tab-Planlar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('saved-tab-Mekanlar')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('saved-places-tab')), findsOneWidget);
    expect(find.text('Minoa Books & Coffee'), findsOneWidget);
  });

  testWidgets('saved search action shows temporary feedback', (tester) async {
    await pumpSavedPage(tester);
    await tester.tap(find.byKey(const ValueKey('saved-search')));
    await tester.pump();

    expect(
      find.text('Kayıtlı içeriklerde arama yakında eklenecek.'),
      findsOneWidget,
    );
  });

  testWidgets('saved add action shows temporary feedback', (tester) async {
    await pumpSavedPage(tester);
    await tester.tap(find.byKey(const ValueKey('saved-add-collection')));
    await tester.pump();

    expect(
      find.text('Yeni koleksiyon oluşturma yakında eklenecek.'),
      findsOneWidget,
    );
  });

  testWidgets('SavedPage bottom navigation marks Kaydedilenler active', (
    tester,
  ) async {
    await pumpSavedPage(tester);

    final navigation = tester.widget<NavigationBar>(
      find.byKey(const ValueKey('app-bottom-navigation')),
    );
    expect(navigation.selectedIndex, 1);
  });

  testWidgets('SavedPage Keşfet destination returns to DiscoverPage', (
    tester,
  ) async {
    await pumpSavedPage(tester);
    await tester.tap(find.text('Keşfet'));
    await tester.pumpAndSettle();

    expect(find.byType(DiscoverPage), findsOneWidget);
  });

  testWidgets('SavedPage AI and profile destinations show feedback', (
    tester,
  ) async {
    await pumpSavedPage(tester);

    const expectations = {
      'AI Asistan': 'AI asistan ekranı yakında eklenecek.',
      'Profil': 'Profil ekranı yakında eklenecek.',
    };
    for (final entry in expectations.entries) {
      await tester.tap(find.text(entry.key));
      await tester.pump();
      expect(find.text(entry.value), findsOneWidget);
    }
  });

  testWidgets('SavedPage does not overflow on a small phone', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpSavedPage(tester);

    expect(find.byType(SavedPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saved plans do not overflow on a small phone', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpSavedPage(tester);
    await tester.tap(find.byKey(const ValueKey('saved-tab-Planlar')));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey('saved-plans-scroll')),
      const Offset(0, -420),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('saved-plans-tab')), findsOneWidget);
    expect(find.text('Eski Şehir Gizemleri'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saved collections scroll horizontally without layout errors', (
    tester,
  ) async {
    await pumpSavedPage(tester);
    final collections = find.byKey(const ValueKey('saved-collections-scroll'));
    await tester.drag(collections, const Offset(-220, 0));
    await tester.pumpAndSettle();

    expect(find.text('Yeni Liste'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
