import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turota_mobile/app/app.dart';

void main() {
  testWidgets('shows the home foundation components', (tester) async {
    await tester.pumpWidget(const TurotaApp());

    expect(find.text('Turota'), findsOneWidget);
    expect(find.text('Keşfetmeye Başla'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
