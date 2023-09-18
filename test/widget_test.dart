// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_one/main.dart'; // Importeringen ser korrekt ut

void main() {
  testWidgets('Test HomePage', (WidgetTester tester) async {
    // Bygg vår app och utlös en frame.
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    // Verifiera att 'Home Page' visas i appbaren.
    expect(find.text('Home Page'), findsOneWidget);

    // Lägg till fler tester som passar din app här
  });
}
