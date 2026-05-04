import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart';
import '../auth/auth_repository.dart';
import '../notifications/notification_repository.dart';

class DashboardData {
  DashboardData({
    required this.totalTasks,
    required this.upcomingDue,
    required this.overdue,
    required this.totalProjects,
    required this.daysRemaining,
    required this.pendingLeave,
  });

  final int totalTasks;
  final int upcomingDue;
  final int overdue;
  final int totalProjects;
  final int daysRemaining;
  final int pendingLeave;

  factory DashboardData.fromJson(Map<String, dynamic> j) => DashboardData(
        totalTasks: (j['tasks'] as Map)['total'] as int? ?? 0,
        upcomingDue: (j['tasks'] as Map)['upcoming_due'] as int? ?? 0,
        overdue: (j['tasks'] as Map)['overdue'] as int? ?? 0,
        totalProjects: (j['projects'] as Map)['total'] as int? ?? 0,
        daysRemaining: (j['leave'] as Map)['days_remaining_year'] as int? ?? 0,
        pendingLeave: (j['leave'] as Map)['pending_applications'] as int? ?? 0,
      );
}

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final r = await ref.read(apiClientProvider).dio.get('/dashboard');
  return DashboardData.fromJson(r.data as Map<String, dynamic>);
});

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dashboardProvider);
    final user = ref.watch(authControllerProvider).user;

    final unreadAsync = ref.watch(unreadCountProvider);
    final unread = unreadAsync.maybeWhen(data: (n) => n, orElse: () => 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push('/notifications'),
              ),
              if (unread > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      unread > 99 ? '99+' : '$unread',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {
            ref.invalidate(dashboardProvider);
            ref.invalidate(unreadCountProvider);
          }),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(dashboardProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (user != null)
              Text('Hello, ${user.name.split(' ').first}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(_greeting(), style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 24),
            data.when(
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
              error: (e, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error: ${ApiClient.describeError(e)}'),
                ),
              ),
              data: (d) => Column(
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _StatCard(
                        title: 'My Tasks',
                        value: '${d.totalTasks}',
                        sub: '${d.overdue} overdue · ${d.upcomingDue} due ≤7d',
                        icon: Icons.task_alt,
                        color: Colors.blue,
                        onTap: () => context.go('/tasks'),
                      ),
                      _StatCard(
                        title: 'Projects',
                        value: '${d.totalProjects}',
                        sub: 'Open project count',
                        icon: Icons.folder_outlined,
                        color: Colors.purple,
                        onTap: () => context.go('/projects'),
                      ),
                      _StatCard(
                        title: 'Leave Days Left',
                        value: '${d.daysRemaining}',
                        sub: '${d.pendingLeave} pending applications',
                        icon: Icons.calendar_month,
                        color: Colors.green,
                        onTap: () => context.go('/leave'),
                      ),
                      _StatCard(
                        title: 'Field Inspections',
                        value: 'Log a visit',
                        sub: 'Capture GPS + photos',
                        icon: Icons.location_on_outlined,
                        color: Colors.orange,
                        onTap: () => context.go('/inspections'),
                      ),
                      _StatCard(
                        title: 'My Appraisals',
                        value: 'View',
                        sub: 'Performance reviews & scores',
                        icon: Icons.assignment_outlined,
                        color: Colors.indigo,
                        onTap: () => context.push('/appraisals'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning.';
    if (h < 17) return 'Good afternoon.';
    return 'Good evening.';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.sub, required this.icon, required this.color, required this.onTap});
  final String title;
  final String value;
  final String sub;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const Spacer(),
                ],
              ),
              const Spacer(),
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(sub, style: const TextStyle(fontSize: 11, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
