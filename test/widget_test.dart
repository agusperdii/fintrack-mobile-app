import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack_mobile_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app builds correctly
    expect(find.text('The Kinetic Vault'), findsOneWidget);
  });
}
