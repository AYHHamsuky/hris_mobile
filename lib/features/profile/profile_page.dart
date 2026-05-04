import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_repository.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
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
              title: const Text('Change Password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/change-password'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
              onTap: () async {
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
