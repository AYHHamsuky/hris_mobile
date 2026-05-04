import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hris_mobile/features/auth/login_page.dart';

void main() {
  testWidgets('Login page renders the brand and Sign in button', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginPage()),
      ),
    );

    expect(find.text('Kaduna Electric'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Email or Payroll ID'), findsOneWidget);
  });
}
