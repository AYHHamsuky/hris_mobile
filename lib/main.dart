import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'core/locale/locale_controller.dart';
import 'core/notifications/push_router.dart';
import 'core/notifications/push_service.dart';
import 'features/auth/auth_repository.dart';
import 'features/inspections/inspection_drafts.dart';
import 'l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialise Firebase if a config file is present. The app continues to work
  // without it — push just no-ops.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }
  runApp(const ProviderScope(child: HrisApp()));
}

class HrisApp extends ConsumerStatefulWidget {
  const HrisApp({super.key});

  @override
  ConsumerState<HrisApp> createState() => _HrisAppState();
}

class _HrisAppState extends ConsumerState<HrisApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = buildRouter(ref);

    Future.microtask(() async {
      await ref.read(authControllerProvider.notifier).bootstrap();
      final user = ref.read(authControllerProvider).user;
      if (user != null) {
        await ref.read(pushServiceProvider).init(
          onMessageOpenedApp: (msg) => handlePushTap(_router, msg),
        );
        await ref.read(inspectionDraftStoreProvider).syncAll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeControllerProvider);
    return MaterialApp.router(
      title: 'Kaduna Electric HRIS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: _router,
      locale: locale,
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
    );
  }
}
