import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart';
import '../../l10n/generated/app_localizations.dart';
import 'performance_repository.dart';

class AppraisalsListPage extends ConsumerWidget {
  const AppraisalsListPage({super.key});

  Color _statusColor(String s) => switch (s) {
        'finalized' => Colors.green,
        'rating' => Colors.purple,
        'tracking' => Colors.amber,
        'planning_agreed' => Colors.blue,
        _ => Colors.grey,
      };

  String _statusLabel(BuildContext context, String s) {
    final l = AppL10n.of(context);
    return switch (s) {
      'draft' => l.appraisalStatusPlanning,
      'planning_agreed' => l.appraisalStatusPlanAgreed,
      'tracking' => l.appraisalStatusTracking,
      'rating' => l.appraisalStatusRating,
      'finalized' => l.appraisalStatusFinalized,
      _ => s,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(myAppraisalsProvider);
    final l = AppL10n.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.appraisalsTitle),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(myAppraisalsProvider)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myAppraisalsProvider),
        child: list.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(ApiClient.describeError(e))),
          data: (rows) {
            if (rows.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(32),
                children: [
                  const Icon(Icons.assignment_outlined, size: 56, color: Colors.black26),
                  const SizedBox(height: 12),
                  Text(l.appraisalsEmpty,
                      textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final r = rows[i];
                return Card(
                  child: ListTile(
                    title: Text(r.cycleName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (r.jobRoleTitle != null) Text(r.jobRoleTitle!, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        if (r.reviewerName != null) Text('Reviewer: ${r.reviewerName!}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _statusColor(r.status).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(_statusLabel(context, r.status),
                                  style: TextStyle(color: _statusColor(r.status), fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                            if (r.overallScore != null && r.overallScore != '0.00' && r.overallScore != 'null')
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(999)),
                                child: Text('Score: ${r.overallScore}%',
                                    style: const TextStyle(color: Colors.indigo, fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/appraisals/${r.id}'),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
