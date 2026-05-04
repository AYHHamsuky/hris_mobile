import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'features/auth/auth_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: HrisApp()));
}

class HrisApp extends ConsumerStatefulWidget {
  const HrisApp({super.key});

  @override
  ConsumerState<HrisApp> createState() => _HrisAppState();
}

class _HrisAppState extends ConsumerState<HrisApp> {
  @override
  void initState() {
    super.initState();
    // Try to restore session from secure storage on launch.
    Future.microtask(() => ref.read(authControllerProvider.notifier).bootstrap());
  }

  @override
  Widget build(BuildContext context) {
    final router = buildRouter(ref);
    return MaterialApp.router(
      title: 'Kaduna Electric HRIS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
