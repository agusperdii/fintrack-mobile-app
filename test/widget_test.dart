import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The root widget_test.dart intentionally avoids importing main.dart or
/// Supabase because doing so would require a real/fake Supabase connection
/// and cause the test to hang indefinitely.
///
/// Full coverage for pages and controllers is in test/unit/ and test/widget/.
void main() {
  testWidgets('MaterialApp scaffolds correctly without Supabase', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Savaio')),
        ),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Savaio'), findsOneWidget);
  });
}
