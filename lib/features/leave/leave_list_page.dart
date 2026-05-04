import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'leave_models.dart';
import 'leave_repository.dart';

class LeaveListPage extends ConsumerWidget {
  const LeaveListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balances = ref.watch(leaveBalancesProvider);
    final apps = ref.watch(myLeaveProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(leaveBalancesProvider);
              ref.invalidate(myLeaveProvider);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/leave/apply'),
        icon: const Icon(Icons.add),
        label: const Text('Apply'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(leaveBalancesProvider);
          ref.invalidate(myLeaveProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
          children: [
            const Text('Balances', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            balances.when(
              loading: () => const Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (list) => Column(children: list.map(_BalanceTile.new).toList()),
            ),
            const SizedBox(height: 24),
            const Text('My Applications', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            apps.when(
              loading: () => const Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (list) {
                if (list.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No leave applications yet.', style: TextStyle(color: Colors.black54)),
                    ),
                  );
                }
                return Column(children: list.map(_LeaveTile.new).toList());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceTile extends StatelessWidget {
  const _BalanceTile(this.b);
  final LeaveBalance b;

  @override
  Widget build(BuildContext context) {
    final pct = b.daysAllowed == 0 ? 0.0 : b.daysTaken / b.daysAllowed;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(b.leaveTypeName, style: const TextStyle(fontWeight: FontWeight.w600))),
                  Text('${b.daysRemaining} left',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.green)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct.clamp(0, 1),
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
              const SizedBox(height: 4),
              Text('${b.daysTaken} taken · ${b.daysPending} pending · ${b.daysAllowed} allowed',
                  style: const TextStyle(fontSize: 11, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaveTile extends StatelessWidget {
  const _LeaveTile(this.app);
  final LeaveApplication app;

  Color _statusColor() => switch (app.status) {
        'approved' => Colors.green,
        'lm_approved' => Colors.blue,
        'pending' => Colors.orange,
        'lm_rejected' || 'rejected' => Colors.red,
        _ => Colors.grey,
      };

  String _statusLabel() => switch (app.status) {
        'pending' => 'Pending LM',
        'lm_approved' => 'Awaiting HR',
        'lm_rejected' => 'Rejected by LM',
        'approved' => 'Approved',
        'rejected' => 'Rejected',
        _ => app.status,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ListTile(
          title: Text(app.leaveTypeName, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('${app.startDate} → ${app.endDate}  ·  ${app.daysRequested} day(s)'),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor().withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(_statusLabel(), style: TextStyle(color: _statusColor(), fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}
