import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turota_mobile/app/app.dart';
import 'package:turota_mobile/app/router/app_router.dart';
import 'package:turota_mobile/core/constants/app_constants.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_theme.dart';
import 'package:turota_mobile/features/authentication/presentation/pages/login_page.dart';
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

  testWidgets('registration placeholder shows its SnackBar', (tester) async {
    await pumpLoginPage(tester);
    await tester.tap(find.text('Kayıt Ol'));
    await tester.pump();

    expect(find.text('Kayıt ol ekranı yakında eklenecek.'), findsOneWidget);
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
}
