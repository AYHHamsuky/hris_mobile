import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_client.dart';
import 'task_models.dart';
import 'task_repository.dart';

final _taskFutureProvider = FutureProvider.family<TaskDetail, int>((ref, id) async {
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

  Future<void> _updateProgress(int currentPct) async {
    var pct = currentPct;
    final result = await showDialog<int>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text('Update progress: $pct%'),
          content: Slider(value: pct.toDouble(), min: 0, max: 100, divisions: 20, onChanged: (v) => setS(() => pct = v.round())),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, pct), child: const Text('Save')),
          ],
        ),
      ),
    );
    if (result == null) return;
    try {
      await ref.read(taskRepositoryProvider).updateProgress(widget.id, percent: result);
      ref.invalidate(_taskFutureProvider(widget.id));
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
        data: (detail) {
          final task = detail.task;
          return RefreshIndicator(
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
                    child: Padding(padding: const EdgeInsets.all(12), child: Text(task.description!)),
                  ),
                const SizedBox(height: 16),

                // State picker
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

                // Progress + meta
                _Row(label: 'Priority', value: task.priority),
                if (task.dueDate != null) _Row(label: 'Due date', value: task.dueDate!),
                if (task.completedDate != null) _Row(label: 'Completed', value: task.completedDate!),
                if (task.estimatedHours != null) _Row(label: 'Estimated', value: '${task.estimatedHours}h'),
                if (task.actualHours != null) _Row(label: 'Actual', value: '${task.actualHours}h'),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Progress', style: TextStyle(color: Colors.black54)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: task.progressPercent / 100,
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade200,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${task.progressPercent}%', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  trailing: TextButton(onPressed: () => _updateProgress(task.progressPercent), child: const Text('Update')),
                ),

                if (task.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Tags', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 6),
                  Wrap(spacing: 6, children: task.tags.map((t) => Chip(label: Text('#$t'))).toList()),
                ],

                if (task.assignees.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Assignees', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 6),
                  Wrap(spacing: 6, children: task.assignees.map((a) => Chip(label: Text(a.name))).toList()),
                ],

                // Attachments
                if (detail.attachments.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Attachments (${detail.attachments.length})', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 6),
                  ...detail.attachments.map((a) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.insert_drive_file),
                          title: Text(a.name),
                          subtitle: a.sizeBytes != null ? Text(_formatBytes(a.sizeBytes!)) : null,
                          trailing: const Icon(Icons.open_in_new, size: 16),
                          onTap: a.url.isEmpty ? null : () => launchUrl(Uri.parse(a.url), mode: LaunchMode.externalApplication),
                        ),
                      )),
                ],

                // Comments
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Text('Comments (${detail.comments.length})', style: Theme.of(context).textTheme.labelMedium)),
                    TextButton.icon(onPressed: _addComment, icon: const Icon(Icons.add, size: 14), label: const Text('Add')),
                  ],
                ),
                if (detail.comments.isEmpty)
                  const Card(
                    child: Padding(padding: EdgeInsets.all(12), child: Text('No comments yet.', style: TextStyle(color: Colors.black54))),
                  )
                else
                  ...detail.comments.map((c) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(radius: 12, child: Text(c.userName.isNotEmpty ? c.userName[0] : '?', style: const TextStyle(fontSize: 11))),
                                  const SizedBox(width: 6),
                                  Text(c.userName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                  const Spacer(),
                                  Text(c.createdAt.split('T').first, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(c.body),
                            ],
                          ),
                        ),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatBytes(int n) {
    if (n < 1024) return '$n B';
    if (n < 1024 * 1024) return '${(n / 1024).toStringAsFixed(1)} KB';
    return '${(n / 1024 / 1024).toStringAsFixed(1)} MB';
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
