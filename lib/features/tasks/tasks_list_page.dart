import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'task_models.dart';
import 'task_repository.dart';

class TasksListPage extends ConsumerStatefulWidget {
  const TasksListPage({super.key});

  @override
  ConsumerState<TasksListPage> createState() => _TasksListPageState();
}

class _TasksListPageState extends ConsumerState<TasksListPage> {
  String? _state;
  String? _priority;
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = TaskFilter(state: _state, priority: _priority, search: _search);
    final tasksAsync = ref.watch(tasksProvider(filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(tasksProvider(filter)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search tasks…',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _search = '');
                        },
                      )
                    : null,
              ),
              onSubmitted: (v) => setState(() => _search = v.trim()),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                FilterChip(
                  label: const Text('All states'),
                  selected: _state == null,
                  onSelected: (_) => setState(() => _state = null),
                ),
                const SizedBox(width: 6),
                ...TaskState.all.map((s) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(TaskState.label(s)),
                        selected: _state == s,
                        onSelected: (_) => setState(() => _state = _state == s ? null : s),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: tasksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorView(message: e.toString(), onRetry: () => ref.invalidate(tasksProvider(filter))),
              data: (tasks) {
                if (tasks.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No tasks match the current filter.', style: TextStyle(color: Colors.black54)),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(tasksProvider(filter)),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _TaskCard(task: tasks[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});
  final Task task;

  Color _statePillColor() => switch (task.state) {
        TaskState.inProgress => Colors.blue.shade100,
        TaskState.changesRequested => Colors.amber.shade100,
        TaskState.approved => Colors.green.shade100,
        TaskState.done => Colors.green.shade200,
        TaskState.cancelled => Colors.red.shade100,
        _ => Colors.grey.shade200,
      };

  Color _priorityColor() => switch (task.priority) {
        'urgent' || 'critical' => Colors.red.shade600,
        'high' => Colors.orange.shade700,
        'medium' => Colors.blue.shade600,
        _ => Colors.grey.shade600,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/tasks/${task.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: task.state == TaskState.done ? TextDecoration.lineThrough : null,
                  color: task.state == TaskState.done ? Colors.black45 : null,
                ),
              ),
              if (task.projectName != null) ...[
                const SizedBox(height: 4),
                Text(task.projectName!, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
              const SizedBox(height: 8),
              if (task.progressPercent > 0) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: task.progressPercent / 100,
                    minHeight: 4,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _Pill(text: TaskState.label(task.state), color: _statePillColor()),
                  _Pill(
                    text: task.priority,
                    color: _priorityColor().withValues(alpha: 0.15),
                    textColor: _priorityColor(),
                  ),
                  if (task.dueDate != null)
                    _Pill(text: 'Due ${task.dueDate}', color: Colors.transparent, textColor: Colors.black54),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color, this.textColor});
  final String text;
  final Color color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(fontSize: 11, color: textColor ?? Colors.black87, fontWeight: FontWeight.w500)),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
