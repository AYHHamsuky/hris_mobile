import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import 'inspection_models.dart';

class InspectionRepository {
  InspectionRepository(this._api);
  final ApiClient _api;

  Future<List<Inspection>> list({int? projectId, bool mineOnly = false}) async {
    final r = await _api.dio.get('/field-inspections', queryParameters: {
      if (projectId != null) 'project_id': projectId,
      if (mineOnly) 'mine': '1',
      'per_page': 50,
    });
    return (r.data['data'] as List).cast<Map<String, dynamic>>().map(Inspection.fromJson).toList();
  }

  Future<List<ProjectOption>> projects() async {
    final r = await _api.dio.get('/projects', queryParameters: {'per_page': 200});
    return (r.data['data'] as List).cast<Map<String, dynamic>>().map(ProjectOption.fromJson).toList();
  }

  Future<Inspection> create({
    required int projectId,
    DateTime? inspectedAt,
    double? latitude,
    double? longitude,
    double? accuracyM,
    String? locationName,
    String? weather,
    int? progressObserved,
    String? notes,
    List<File> media = const [],
  }) async {
    final form = FormData.fromMap({
      'project_id': projectId,
      if (inspectedAt != null) 'inspected_at': inspectedAt.toIso8601String(),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (accuracyM != null) 'accuracy_m': accuracyM,
      if (locationName != null && locationName.isNotEmpty) 'location_name': locationName,
      if (weather != null) 'weather': weather,
      if (progressObserved != null) 'progress_observed': progressObserved,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      'media': [
        for (final f in media)
          await MultipartFile.fromFile(f.path, filename: f.path.split('/').last),
      ],
    });
    final r = await _api.dio.post('/field-inspections', data: form);
    return Inspection.fromJson(r.data['data'] as Map<String, dynamic>);
  }
}

final inspectionRepoProvider = Provider<InspectionRepository>((ref) {
  return InspectionRepository(ref.read(apiClientProvider));
});

final inspectionsProvider = FutureProvider<List<Inspection>>((ref) async {
  return ref.read(inspectionRepoProvider).list(mineOnly: true);
});

final projectOptionsProvider = FutureProvider<List<ProjectOption>>((ref) async {
  return ref.read(inspectionRepoProvider).projects();
});
