import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turota_mobile/app/app.dart';
import 'package:turota_mobile/core/constants/app_constants.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/features/splash/presentation/pages/splash_page.dart';

void main() {
  testWidgets('SplashPage is shown first', (tester) async {
    await tester.pumpWidget(const TurotaApp());

    expect(find.byType(SplashPage), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('SplashPage contains the local logo asset', (tester) async {
    await tester.pumpWidget(const TurotaApp());

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<AssetImage>());
    expect((image.image as AssetImage).assetName, AppConstants.logoAssetPath);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('SplashPage uses the branded background', (tester) async {
    await tester.pumpWidget(const TurotaApp());

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppColors.splashBackground);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('transitions to the placeholder home page', (tester) async {
    await tester.pumpWidget(const TurotaApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(SplashPage), findsNothing);
    expect(find.text('Turota'), findsOneWidget);
    expect(find.text('Keşfetmeye Başla'), findsOneWidget);
  });
}
