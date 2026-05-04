import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'inspection_repository.dart';

/// One pending inspection waiting for upload.
class InspectionDraft {
  InspectionDraft({
    required this.id,
    required this.projectId,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.accuracyM,
    this.locationName,
    this.weather,
    this.progressObserved,
    this.notes,
    this.mediaPaths = const [],
    this.lastError,
  });

  final String id; // local UUID-ish
  final int projectId;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;
  final double? accuracyM;
  final String? locationName;
  final String? weather;
  final int? progressObserved;
  final String? notes;
  final List<String> mediaPaths;
  final String? lastError;

  Map<String, dynamic> toJson() => {
        'id': id,
        'project_id': projectId,
        'created_at': createdAt.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'accuracy_m': accuracyM,
        'location_name': locationName,
        'weather': weather,
        'progress_observed': progressObserved,
        'notes': notes,
        'media_paths': mediaPaths,
        'last_error': lastError,
      };

  factory InspectionDraft.fromJson(Map<String, dynamic> j) => InspectionDraft(
        id: j['id'] as String,
        projectId: j['project_id'] as int,
        createdAt: DateTime.parse(j['created_at'] as String),
        latitude: (j['latitude'] as num?)?.toDouble(),
        longitude: (j['longitude'] as num?)?.toDouble(),
        accuracyM: (j['accuracy_m'] as num?)?.toDouble(),
        locationName: j['location_name'] as String?,
        weather: j['weather'] as String?,
        progressObserved: j['progress_observed'] as int?,
        notes: j['notes'] as String?,
        mediaPaths: (j['media_paths'] as List?)?.cast<String>() ?? const [],
        lastError: j['last_error'] as String?,
      );

  InspectionDraft withError(String? err) => InspectionDraft(
        id: id, projectId: projectId, createdAt: createdAt,
        latitude: latitude, longitude: longitude, accuracyM: accuracyM,
        locationName: locationName, weather: weather, progressObserved: progressObserved,
        notes: notes, mediaPaths: mediaPaths, lastError: err,
      );
}

class InspectionDraftStore {
  InspectionDraftStore(this._repo);
  final InspectionRepository _repo;

  static const _key = 'inspection_drafts_v1';

  Future<List<InspectionDraft>> all() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const [];
    return raw.map((s) => InspectionDraft.fromJson(jsonDecode(s) as Map<String, dynamic>)).toList();
  }

  Future<void> _save(List<InspectionDraft> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, list.map((d) => jsonEncode(d.toJson())).toList());
  }

  Future<void> add(InspectionDraft draft) async {
    final list = await all();
    list.add(draft);
    await _save(list);
  }

  Future<void> remove(String id) async {
    final list = await all();
    list.removeWhere((d) => d.id == id);
    await _save(list);
  }

  Future<void> updateError(String id, String err) async {
    final list = await all();
    final idx = list.indexWhere((d) => d.id == id);
    if (idx >= 0) {
      list[idx] = list[idx].withError(err);
      await _save(list);
    }
  }

  /// Try to upload every pending draft. Returns the count successfully synced.
  /// Skips entirely if there is no network connectivity.
  Future<int> syncAll() async {
    final result = await Connectivity().checkConnectivity();
    final hasNet = result.any((r) => r != ConnectivityResult.none);
    if (!hasNet) return 0;

    final list = await all();
    int synced = 0;
    for (final draft in list) {
      try {
        final files = draft.mediaPaths
            .map((p) => File(p))
            .where((f) => f.existsSync())
            .toList();

        await _repo.create(
          projectId: draft.projectId,
          inspectedAt: draft.createdAt,
          latitude: draft.latitude,
          longitude: draft.longitude,
          accuracyM: draft.accuracyM,
          locationName: draft.locationName,
          weather: draft.weather,
          progressObserved: draft.progressObserved,
          notes: draft.notes,
          media: files,
        );
        await remove(draft.id);
        synced++;
      } catch (e) {
        await updateError(draft.id, e.toString());
      }
    }
    return synced;
  }
}

final inspectionDraftStoreProvider = Provider<InspectionDraftStore>((ref) {
  return InspectionDraftStore(ref.read(inspectionRepoProvider));
});

final inspectionDraftsProvider = FutureProvider<List<InspectionDraft>>((ref) async {
  return ref.read(inspectionDraftStoreProvider).all();
});
