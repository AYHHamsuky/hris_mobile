import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import 'performance_repository.dart';

class AppraisalDetailPage extends ConsumerWidget {
  const AppraisalDetailPage({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(appraisalDetailProvider(id));

    return Scaffold(
      appBar: AppBar(title: const Text('Appraisal')),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(ApiClient.describeError(e))),
        data: (d) {
          // Group objectives by BSC category
          final byCat = <String, List<AppraisalObjective>>{};
          for (final o in d.objectives) {
            (byCat[o.bscCategory] ??= []).add(o);
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(appraisalDetailProvider(id)),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.cycleName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        if (d.jobRoleTitle != null) Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(d.jobRoleTitle!, style: const TextStyle(color: Colors.black54)),
                        ),
                        const SizedBox(height: 8),
                        Wrap(spacing: 6, runSpacing: 4, children: [
                          _Pill('Phase: ${d.cyclePhase}', Colors.indigo),
                          _Pill('Status: ${d.status}', Colors.blue),
                          if (d.overallScore != null && d.overallScore != '0.00' && d.overallScore != 'null')
                            _Pill('Score: ${d.overallScore}%', Colors.green),
                          if (d.hrApprovedAt != null) _Pill('HR Approved', Colors.green),
                          if (d.hrRejectedAt != null) _Pill('HR Rejected', Colors.red),
                          if (d.planningLockedAt != null) _Pill('Plan Locked', Colors.grey),
                          if (d.trackingLockedAt != null) _Pill('Tracking Locked', Colors.grey),
                        ]),
                      ],
                    ),
                  ),
                ),

                if (d.hrRejectionReason != null && d.hrRejectionReason!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('HR rejection reason', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(d.hrRejectionReason!, style: const TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                Text('Objectives (${d.objectives.length})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 6),

                for (final cat in byCat.keys) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
                    child: Text(cat, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 12)),
                  ),
                  Card(
                    child: Column(
                      children: [
                        for (var i = 0; i < byCat[cat]!.length; i++) ...[
                          if (i > 0) const Divider(height: 1),
                          _ObjectiveTile(o: byCat[cat]![i]),
                        ],
                      ],
                    ),
                  ),
                ],

                if (d.selfAssessment != null && d.selfAssessment!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Self assessment', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 6),
                  Card(
                    child: Padding(padding: const EdgeInsets.all(12), child: Text(d.selfAssessment!)),
                  ),
                ],

                if (d.reviewerComments != null && d.reviewerComments!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Reviewer comments', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 6),
                  Card(
                    child: Padding(padding: const EdgeInsets.all(12), child: Text(d.reviewerComments!)),
                  ),
                ],

                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
                  child: const Text(
                    'Editing, rating, and agreement actions are only available on the web.\n'
                    'Sign in at kadunaelectric.cloud to act on this appraisal.',
                    style: TextStyle(fontSize: 12, color: Colors.brown),
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

class _ObjectiveTile extends StatelessWidget {
  const _ObjectiveTile({required this.o});
  final AppraisalObjective o;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(o.description, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (o.kpi != null && o.kpi!.isNotEmpty)
              Text('KPI: ${o.kpi}', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Wrap(spacing: 6, runSpacing: 4, children: [
              if (o.weight != null) _MiniPill('Wt ${o.weight}%', Colors.blue),
              if (o.target != null && o.target!.isNotEmpty) _MiniPill('Target ${o.target}', Colors.grey),
              if (o.score != null) _MiniPill('Score ${o.score}/5', Colors.green),
              if (o.selfRating != null) _MiniPill('Self ${o.selfRating}/5', Colors.amber),
              if (o.progressStatus != null) _MiniPill(o.progressStatus!, Colors.purple),
            ]),
            if (o.managerComment != null && o.managerComment!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Manager: ${o.managerComment}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black54)),
            ],
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text, this.color);
  final String text;
  final MaterialColor color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(color: color.shade700, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill(this.text, this.color);
  final String text;
  final MaterialColor color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(color: color.shade50, borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(color: color.shade700, fontSize: 10)),
    );
  }
}
