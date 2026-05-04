import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import 'leave_repository.dart';

class TeamLeavePage extends ConsumerStatefulWidget {
  const TeamLeavePage({super.key});

  @override
  ConsumerState<TeamLeavePage> createState() => _TeamLeavePageState();
}

class _TeamLeavePageState extends ConsumerState<TeamLeavePage> {
  Future<void> _approve(TeamLeaveItem item) async {
    final ok = await _confirm('Approve ${item.employeeName}\'s leave request?');
    if (!ok) return;
    try {
      await ref.read(leaveRepositoryProvider).lmApprove(item.id);
      ref.invalidate(teamLeaveProvider);
      _toast('Approved. HR has been notified.');
    } catch (e) {
      _toast(ApiClient.describeError(e));
    }
  }

  Future<void> _reject(TeamLeaveItem item) async {
    final reason = await _askReason();
    if (reason == null || reason.isEmpty) return;
    try {
      await ref.read(leaveRepositoryProvider).lmReject(item.id, reason);
      ref.invalidate(teamLeaveProvider);
      _toast('Rejected. Employee has been notified.');
    } catch (e) {
      _toast(ApiClient.describeError(e));
    }
  }

  Future<bool> _confirm(String msg) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            content: Text(msg),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Approve')),
            ],
          ),
        ) ??
        false;
  }

  Future<String?> _askReason() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rejection reason'),
        content: TextField(controller: ctrl, maxLines: 3, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Reject')),
        ],
      ),
    );
  }

  void _toast(String msg) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(teamLeaveProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Leave'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(teamLeaveProvider)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(teamLeaveProvider),
        child: items.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (list) {
            if (list.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(32),
                children: const [
                  Icon(Icons.inbox, size: 56, color: Colors.black26),
                  SizedBox(height: 12),
                  Text('No pending leave from your team.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _TeamLeaveCard(item: list[i], onApprove: _approve, onReject: _reject),
            );
          },
        ),
      ),
    );
  }
}

class _TeamLeaveCard extends StatelessWidget {
  const _TeamLeaveCard({required this.item, required this.onApprove, required this.onReject});
  final TeamLeaveItem item;
  final void Function(TeamLeaveItem) onApprove;
  final void Function(TeamLeaveItem) onReject;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(item.employeeName, style: const TextStyle(fontWeight: FontWeight.w600))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(999)),
                  child: Text(_statusLabel(), style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            if (item.department != null) ...[
              const SizedBox(height: 2),
              Text(item.department!, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
            const SizedBox(height: 8),
            Text('${item.leaveTypeName} · ${item.daysRequested} day(s)', style: const TextStyle(fontSize: 13)),
            Text('${item.startDate}  →  ${item.endDate}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
            if (item.reason != null && item.reason!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('"${item.reason!}"', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black54)),
            ],
            const SizedBox(height: 12),
            if (item.status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onReject(item),
                      icon: const Icon(Icons.close, size: 16, color: Colors.red),
                      label: const Text('Reject', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => onApprove(item),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve'),
                    ),
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                child: const Text('Awaiting HR final approval', style: TextStyle(color: Colors.blue, fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }

  String _statusLabel() => item.status == 'pending' ? 'Pending' : 'LM Approved';
}
