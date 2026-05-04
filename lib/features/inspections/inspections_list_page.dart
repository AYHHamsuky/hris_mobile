import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'inspection_models.dart';
import 'inspection_repository.dart';

class InspectionsListPage extends ConsumerWidget {
  const InspectionsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inspections = ref.watch(inspectionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Inspections'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(inspectionsProvider)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/inspections/new'),
        icon: const Icon(Icons.add_location_alt),
        label: const Text('New'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(inspectionsProvider),
        child: inspections.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (list) {
            if (list.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(32),
                children: const [
                  Icon(Icons.location_searching, size: 56, color: Colors.black26),
                  SizedBox(height: 12),
                  Text('No inspections yet.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
                  SizedBox(height: 4),
                  Text('Tap "New" to record your first site visit.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black45, fontSize: 12)),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _InspectionCard(insp: list[i]),
            );
          },
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
