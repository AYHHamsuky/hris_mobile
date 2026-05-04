import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart';
import '../tasks/task_models.dart';

class ProjectDetail {
  ProjectDetail({
    required this.id,
    required this.name,
    required this.tasks,
    required this.milestones,
    this.description,
    this.status,
    this.priority,
    this.startDate,
    this.endDate,
  });

  final int id;
  final String name;
  final String? description;
  final String? status;
  final String? priority;
  final String? startDate;
  final String? endDate;
  final List<Task> tasks;
  final List<MilestoneSummary> milestones;

  factory ProjectDetail.fromJson(Map<String, dynamic> root) {
    final p = root['data'] as Map<String, dynamic>;
    final t = (root['tasks'] as List? ?? const []).cast<Map<String, dynamic>>();
    final ms = (p['milestones'] as List? ?? const []).cast<Map<String, dynamic>>();

    return ProjectDetail(
      id: p['id'] as int,
      name: p['name'] as String,
      description: p['description'] as String?,
      status: p['status'] as String?,
      priority: p['priority'] as String?,
      startDate: p['start_date'] as String?,
      endDate: p['end_date'] as String?,
      tasks: t.map(Task.fromJson).toList(),
      milestones: ms.map(MilestoneSummary.fromJson).toList(),
    );
  }
}

class MilestoneSummary {
  MilestoneSummary({required this.id, required this.name, required this.isCompleted, this.dueDate});
  final int id;
  final String name;
  final bool isCompleted;
  final String? dueDate;

  factory MilestoneSummary.fromJson(Map<String, dynamic> j) => MilestoneSummary(
        id: j['id'] as int,
        name: j['name'] as String,
        isCompleted: j['is_completed'] as bool? ?? (j['completed_at'] != null),
        dueDate: j['due_date'] as String?,
      );
}

final projectDetailProvider = FutureProvider.family<ProjectDetail, int>((ref, id) async {
  final r = await ref.read(apiClientProvider).dio.get('/projects/$id');
  return ProjectDetail.fromJson(r.data as Map<String, dynamic>);
});

class ProjectDetailPage extends ConsumerWidget {
  const ProjectDetailPage({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(projectDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(projectDetailProvider(id))),
        ],
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(ApiClient.describeError(e))),
        data: (p) {
          final byState = <String, List<Task>>{
            for (final s in TaskState.all) s: [],
          };
          for (final t in p.tasks) {
            (byState[t.state] ?? byState[TaskState.backlog])!.add(t);
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(projectDetailProvider(id)),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              children: [
                // Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        if (p.description != null && p.description!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(p.description!, style: const TextStyle(color: Colors.black54)),
                        ],
                        const SizedBox(height: 10),
                        Wrap(spacing: 6, runSpacing: 4, children: [
                          if (p.status != null) _Pill(p.status!, Colors.blue),
                          if (p.priority != null) _Pill(p.priority!, Colors.orange),
                          if (p.startDate != null && p.endDate != null)
                            _Pill('${p.startDate} → ${p.endDate}', Colors.grey),
                        ]),
                        const SizedBox(height: 10),
                        Text('${p.tasks.length} task(s) · ${p.milestones.length} milestone(s)',
                            style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Milestones
                if (p.milestones.isNotEmpty) ...[
                  const Text('Milestones', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 6),
                  Card(
                    child: Column(
                      children: [
                        for (var i = 0; i < p.milestones.length; i++) ...[
                          if (i > 0) const Divider(height: 1),
                          ListTile(
                            leading: Icon(
                              p.milestones[i].isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: p.milestones[i].isCompleted ? Colors.green : Colors.black38,
                            ),
                            title: Text(p.milestones[i].name,
                                style: TextStyle(
                                  decoration: p.milestones[i].isCompleted ? TextDecoration.lineThrough : null,
                                  color: p.milestones[i].isCompleted ? Colors.black54 : Colors.black,
                                )),
                            trailing: p.milestones[i].dueDate != null
                                ? Text('Due ${p.milestones[i].dueDate}', style: const TextStyle(fontSize: 11))
                                : null,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Tasks grouped by Odoo state
                const Text('Tasks', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 6),
                for (final s in TaskState.all)
                  if ((byState[s] ?? []).isNotEmpty) _StateGroup(label: TaskState.label(s), tasks: byState[s]!),
                if (p.tasks.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No tasks in this project yet.', style: TextStyle(color: Colors.black54)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StateGroup extends StatelessWidget {
  const _StateGroup({required this.label, required this.tasks});
  final String label;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text('$label  ·  ${tasks.length}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
          ),
          Card(
            child: Column(
              children: [
                for (var i = 0; i < tasks.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  ListTile(
                    title: Text(tasks[i].title, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: tasks[i].dueDate != null ? Text('Due ${tasks[i].dueDate}') : null,
                    trailing: Text(tasks[i].priority, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                    onTap: () => context.push('/tasks/${tasks[i].id}'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text, this.color);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(color: color.shade700IfPossible(), fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

extension on Color {
  Color shade700IfPossible() => this is MaterialColor ? (this as MaterialColor).shade700 : this;
}
