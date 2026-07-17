import 'package:flutter_test/flutter_test.dart';
import 'package:turota_mobile/main.dart';

void main() {
  testWidgets('shows the Turota placeholder', (tester) async {
    await tester.pumpWidget(const MainApp());

    expect(find.text('Turota'), findsOneWidget);
  });
}
