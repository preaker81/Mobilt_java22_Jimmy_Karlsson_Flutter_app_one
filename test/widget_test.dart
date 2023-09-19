import 'package:flutter/material.dart';
import 'package:flutter_app_one/home_page.dart'; // Uppdaterad import
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test HomePage', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    expect(find.text('Home Page'), findsOneWidget);
  });
}
