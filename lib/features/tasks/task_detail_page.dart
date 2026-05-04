import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import 'task_models.dart';
import 'task_repository.dart';

final _taskFutureProvider = FutureProvider.family<Task, int>((ref, id) async {
  return ref.read(taskRepositoryProvider).show(id);
});

class TaskDetailPage extends ConsumerStatefulWidget {
  const TaskDetailPage({super.key, required this.id});
  final int id;

  @override
  ConsumerState<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends ConsumerState<TaskDetailPage> {
  bool _busy = false;

  Future<void> _changeState(String newState) async {
    setState(() => _busy = true);
    try {
      await ref.read(taskRepositoryProvider).updateState(widget.id, newState);
      ref.invalidate(_taskFutureProvider(widget.id));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ApiClient.describeError(e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addComment() async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(controller: ctrl, maxLines: 4, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Post')),
        ],
      ),
    );
    if (result == null || result.isEmpty) return;
    try {
      await ref.read(taskRepositoryProvider).addComment(widget.id, result);
      ref.invalidate(_taskFutureProvider(widget.id));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comment posted.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ApiClient.describeError(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(_taskFutureProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task'),
        actions: [
          IconButton(icon: const Icon(Icons.comment_outlined), onPressed: _addComment),
        ],
      ),
      body: taskAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (task) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(_taskFutureProvider(widget.id)),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(task.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              if (task.projectName != null) ...[
                const SizedBox(height: 4),
                Text(task.projectName!, style: const TextStyle(color: Colors.black54)),
              ],
              const SizedBox(height: 12),
              if (task.description != null && task.description!.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(task.description!),
                  ),
                ),
              const SizedBox(height: 16),
              Text('State', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6, runSpacing: 6,
                children: TaskState.all.map((s) {
                  final selected = s == task.state;
                  return ChoiceChip(
                    label: Text(TaskState.label(s)),
                    selected: selected,
                    onSelected: _busy || selected ? null : (_) => _changeState(s),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              if (task.dueDate != null)
                _Row(label: 'Due date', value: task.dueDate!),
              if (task.completedDate != null)
                _Row(label: 'Completed', value: task.completedDate!),
              _Row(label: 'Priority', value: task.priority),
              _Row(label: 'Progress', value: '${task.progressPercent}%'),
              if (task.estimatedHours != null)
                _Row(label: 'Estimated', value: '${task.estimatedHours}h'),
              if (task.actualHours != null)
                _Row(label: 'Actual', value: '${task.actualHours}h'),
              if (task.assignees.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Assignees', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: task.assignees.map((a) => Chip(label: Text(a.name))).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.black54))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
