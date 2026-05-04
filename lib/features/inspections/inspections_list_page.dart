import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'inspection_drafts.dart';
import 'inspection_models.dart';
import 'inspection_repository.dart';

class InspectionsListPage extends ConsumerStatefulWidget {
  const InspectionsListPage({super.key});

  @override
  ConsumerState<InspectionsListPage> createState() => _InspectionsListPageState();
}

class _InspectionsListPageState extends ConsumerState<InspectionsListPage> {
  bool _syncing = false;

  Future<void> _syncDrafts() async {
    setState(() => _syncing = true);
    try {
      final n = await ref.read(inspectionDraftStoreProvider).syncAll();
      ref.invalidate(inspectionDraftsProvider);
      ref.invalidate(inspectionsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(n == 0 ? 'No drafts to sync (or no internet).' : 'Synced $n draft(s).'),
        ));
      }
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inspections = ref.watch(inspectionsProvider);
    final drafts = ref.watch(inspectionDraftsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Inspections'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {
            ref.invalidate(inspectionsProvider);
            ref.invalidate(inspectionDraftsProvider);
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/inspections/new'),
        icon: const Icon(Icons.add_location_alt),
        label: const Text('New'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(inspectionsProvider);
          ref.invalidate(inspectionDraftsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
          children: [
            // Pending drafts banner
            drafts.maybeWhen(
              data: (list) => list.isEmpty
                  ? const SizedBox.shrink()
                  : Card(
                      color: Colors.amber.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.cloud_upload, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('${list.length} draft(s) waiting to sync',
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            FilledButton.tonal(
                              onPressed: _syncing ? null : _syncDrafts,
                              child: _syncing
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Text('Sync now'),
                            ),
                          ],
                        ),
                      ),
                    ),
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: 8),
            inspections.when(
              loading: () => const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text(e.toString())),
              data: (list) {
                if (list.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: const [
                        Icon(Icons.location_searching, size: 56, color: Colors.black26),
                        SizedBox(height: 12),
                        Text('No inspections yet.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
                        SizedBox(height: 4),
                        Text('Tap "New" to record your first site visit.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black45, fontSize: 12)),
                      ],
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final insp in list) ...[
                      _InspectionCard(insp: insp),
                      const SizedBox(height: 8),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InspectionCard extends StatelessWidget {
  const _InspectionCard({required this.insp});
  final Inspection insp;

  @override
  Widget build(BuildContext context) {
    final photos = insp.media.where((m) => m.kind == 'photo').take(3).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(insp.projectName ?? 'Inspection', style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                Text(insp.inspectedAt.split('T').first, style: const TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
            if (insp.locationName != null) ...[
              const SizedBox(height: 4),
              Text(insp.locationName!, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
            if (insp.osmUrl != null) ...[
              const SizedBox(height: 6),
              InkWell(
                onTap: () => launchUrl(Uri.parse(insp.osmUrl!), mode: LaunchMode.externalApplication),
                child: Row(children: [
                  const Icon(Icons.map_outlined, size: 14, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text('${insp.latitude}, ${insp.longitude}',
                      style: const TextStyle(color: Colors.blue, fontSize: 12)),
                ]),
              ),
            ],
            if (insp.weather != null || insp.progressObserved != null) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children: [
                  if (insp.weather != null)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text(insp.weather!.replaceAll('_', ' '), style: const TextStyle(fontSize: 11)),
                    ),
                  if (insp.progressObserved != null)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text('${insp.progressObserved}% progress', style: const TextStyle(fontSize: 11)),
                    ),
                ],
              ),
            ],
            if (photos.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 64,
                child: Row(
                  children: photos
                      .map((p) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(p.url, height: 64, width: 64, fit: BoxFit.cover),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
            if (insp.media.length > photos.length)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('+ ${insp.media.length - photos.length} more files',
                    style: const TextStyle(fontSize: 11, color: Colors.black54)),
              ),
          ],
        ),
      ),
    );
  }
}
