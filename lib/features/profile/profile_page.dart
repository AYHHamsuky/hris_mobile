import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/biometric_service.dart';
import '../../core/locale/locale_controller.dart';
import '../../core/notifications/push_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../auth/auth_repository.dart';

final _biometricEnabledProvider = FutureProvider<bool>((ref) async {
  return ref.read(biometricServiceProvider).isEnabled();
});

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final biometricEnabled = ref.watch(_biometricEnabledProvider);
    final locale = ref.watch(localeControllerProvider);
    final l = AppL10n.of(context);
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: Text(l.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
              child: user.photoUrl == null
                  ? Text(user.name.split(' ').take(2).map((p) => p[0]).join(),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700))
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
          if (user.position != null) Center(child: Text(user.position!, style: const TextStyle(color: Colors.black54))),
          if (user.department != null) Center(child: Text(user.department!, style: const TextStyle(color: Colors.black54, fontSize: 12))),
          const SizedBox(height: 24),
          _Tile(label: 'Email', value: user.email),
          if (user.payrollId != null) _Tile(label: 'Payroll ID', value: user.payrollId!),
          _Tile(label: 'Role', value: user.role),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: Text(l.profileChangePassword),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/change-password'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text(l.profileLanguage),
              subtitle: Text(_languageLabel(locale)),
              trailing: PopupMenuButton<Locale?>(
                initialValue: locale,
                onSelected: (v) => ref.read(localeControllerProvider.notifier).set(v),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: null, child: Text('System default')),
                  PopupMenuItem(value: Locale('en'), child: Text('English')),
                  PopupMenuItem(value: Locale('ha'), child: Text('Hausa')),
                ],
                icon: const Icon(Icons.expand_more),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.fingerprint),
              title: Text(l.profileBiometric),
              subtitle: Text(l.profileBiometricSub),
              value: biometricEnabled.maybeWhen(data: (v) => v, orElse: () => false),
              onChanged: (v) async {
                final svc = ref.read(biometricServiceProvider);
                if (v) {
                  if (!await svc.supported) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Biometrics not available on this device.'),
                      ));
                    }
                    return;
                  }
                  final ok = await svc.authenticate(reason: 'Confirm to enable biometric unlock');
                  if (!ok) return;
                  await svc.setEnabled(true);
                } else {
                  await svc.setEnabled(false);
                }
                ref.invalidate(_biometricEnabledProvider);
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(l.profileSignOut, style: const TextStyle(color: Colors.red)),
              onTap: () async {
                // Best-effort: tell the server to forget this device's FCM token.
                await ref.read(pushServiceProvider).deregister();
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ),
        ],
      ),
    );
  }
}

String _languageLabel(Locale? locale) {
  if (locale == null) return 'System default';
  return switch (locale.languageCode) {
    'en' => 'English',
    'ha' => 'Hausa',
    _ => locale.languageCode,
  };
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
        dense: true,
      ),
    );
  }
}
