import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turota_mobile/app/app.dart';
import 'package:turota_mobile/app/router/app_router.dart';
import 'package:turota_mobile/core/constants/app_constants.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_theme.dart';
import 'package:turota_mobile/features/authentication/presentation/pages/login_page.dart';
import 'package:turota_mobile/features/authentication/presentation/pages/register_page.dart';
import 'package:turota_mobile/features/home/presentation/pages/placeholder_home_page.dart';
import 'package:turota_mobile/features/onboarding/location/presentation/pages/location_permission_page.dart';
import 'package:turota_mobile/features/splash/presentation/pages/splash_page.dart';

void main() {
  Future<void> pumpToLocationPermission(WidgetTester tester) async {
    await tester.pumpWidget(const TurotaApp());
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
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: const LoginPage(),
      ),
    );
  }

  Future<void> pumpRegisterPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: const RegisterPage(),
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
    await tester.pumpWidget(const TurotaApp());

    expect(find.byType(SplashPage), findsOneWidget);

    await tester.pump(AppConstants.splashDisplayDuration);
    await tester.pumpAndSettle();
  });

  testWidgets('SplashPage contains the local logo asset', (tester) async {
    await tester.pumpWidget(const TurotaApp());

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<AssetImage>());
    expect((image.image as AssetImage).assetName, AppConstants.logoAssetPath);

    await tester.pump(AppConstants.splashDisplayDuration);
    await tester.pumpAndSettle();
  });

  testWidgets('SplashPage uses the branded background', (tester) async {
    await tester.pumpWidget(const TurotaApp());

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

  testWidgets('valid temporary login opens the placeholder home', (
    tester,
  ) async {
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

    expect(find.byType(PlaceholderHomePage), findsOneWidget);
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

  testWidgets('valid temporary registration opens placeholder home', (
    tester,
  ) async {
    await pumpRegisterPage(tester);
    await fillRegistration(tester);
    await submitRegistration(tester);
    await tester.pumpAndSettle();

    expect(find.byType(PlaceholderHomePage), findsOneWidget);
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
}
