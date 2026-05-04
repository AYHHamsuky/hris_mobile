import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hris_mobile/features/auth/login_page.dart';
import 'package:hris_mobile/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('Login page renders the brand and Sign in button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: const LoginPage(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Kaduna Electric'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
