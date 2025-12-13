// This is a basic Flutter widget test for the Banking App.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:banking_app/main.dart';

void main() {
  testWidgets('Banking app shows login screen when not authenticated',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BankingApp());

    // Wait for initialization to complete
    await tester.pumpAndSettle();

    // Verify that the login screen is shown
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('Login screen has email and password fields',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BankingApp());

    // Wait for initialization to complete
    await tester.pumpAndSettle();

    // Verify that email and password fields are present
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Email or Phone'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
