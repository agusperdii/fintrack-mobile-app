import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savaio/main.dart';
import 'package:savaio/core/utils/service_locator.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // Initialize dependencies
    sl.setup();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app builds correctly
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
