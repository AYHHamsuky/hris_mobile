import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart';

class ProjectListItem {
  ProjectListItem({required this.id, required this.name, this.status, this.tasksCount = 0});
  final int id;
  final String name;
  final String? status;
  final int tasksCount;

  factory ProjectListItem.fromJson(Map<String, dynamic> j) => ProjectListItem(
        id: j['id'] as int,
        name: j['name'] as String,
        status: j['status'] as String?,
        tasksCount: j['tasks_count'] as int? ?? 0,
      );
}

final projectsListProvider = FutureProvider<List<ProjectListItem>>((ref) async {
  final r = await ref.read(apiClientProvider).dio.get('/projects', queryParameters: {'per_page': 50});
  return (r.data['data'] as List).cast<Map<String, dynamic>>().map(ProjectListItem.fromJson).toList();
});

class ProjectsListPage extends ConsumerWidget {
  const ProjectsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(projectsListProvider)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(projectsListProvider),
        child: projects.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (list) {
            if (list.isEmpty) {
              return const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No projects assigned to you yet.', style: TextStyle(color: Colors.black54))));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(list[i].name[0].toUpperCase())),
                  title: Text(list[i].name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${list[i].tasksCount} task(s) · ${list[i].status ?? '—'}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/projects/${list[i].id}'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
