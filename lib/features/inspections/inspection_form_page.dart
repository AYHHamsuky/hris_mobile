import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../core/api/api_client.dart';
import 'inspection_drafts.dart';
import 'inspection_models.dart';
import 'inspection_repository.dart';

class InspectionFormPage extends ConsumerStatefulWidget {
  const InspectionFormPage({super.key});

  @override
  ConsumerState<InspectionFormPage> createState() => _InspectionFormPageState();
}

class _InspectionFormPageState extends ConsumerState<InspectionFormPage> {
  ProjectOption? _project;
  Position? _position;
  bool _capturingGps = false;
  String? _gpsError;
  String _weather = '';
  int _progress = 0;
  final _location = TextEditingController();
  final _notes = TextEditingController();
  final List<File> _files = [];
  bool _saving = false;
  String? _error;

  static const _weathers = [
    'sunny', 'partly_cloudy', 'cloudy', 'rainy', 'stormy', 'foggy', 'windy', 'hot', 'cool',
  ];

  @override
  void dispose() {
    _location.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _captureGps() async {
    setState(() {
      _capturingGps = true;
      _gpsError = null;
    });
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        throw 'Location permission permanently denied. Enable it in Settings.';
      }
      if (perm == LocationPermission.denied) {
        throw 'Location permission denied.';
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)),
      );
      setState(() => _position = pos);
    } catch (e) {
      setState(() => _gpsError = e.toString());
    } finally {
      if (mounted) setState(() => _capturingGps = false);
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final shot = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (shot != null) setState(() => _files.add(File(shot.path)));
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final shots = await picker.pickMultiImage(imageQuality: 85);
    setState(() => _files.addAll(shots.map((x) => File(x.path))));
  }

  Future<void> _pickFiles() async {
    final res = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (res != null) {
      setState(() => _files.addAll(res.paths.whereType<String>().map((p) => File(p))));
    }
  }

  Future<void> _submit() async {
    if (_project == null) {
      setState(() => _error = 'Please choose a project.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(inspectionRepoProvider).create(
            projectId: _project!.id,
            inspectedAt: DateTime.now(),
            latitude: _position?.latitude,
            longitude: _position?.longitude,
            accuracyM: _position?.accuracy,
            locationName: _location.text.trim(),
            weather: _weather.isEmpty ? null : _weather,
            progressObserved: _progress > 0 ? _progress : null,
            notes: _notes.text.trim(),
            media: _files,
          );
      ref.invalidate(inspectionsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inspection saved.')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Save the draft locally so it auto-syncs when online.
      await _saveAsDraft();
      ref.invalidate(inspectionDraftsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Saved as draft — we'll upload when you're back online."),
        ));
        Navigator.of(context).pop();
      }
      setState(() => _error = ApiClient.describeError(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveAsDraft() async {
    final draft = InspectionDraft(
      id: 'draft_${DateTime.now().microsecondsSinceEpoch}',
      projectId: _project!.id,
      createdAt: DateTime.now(),
      latitude: _position?.latitude,
      longitude: _position?.longitude,
      accuracyM: _position?.accuracy,
      locationName: _location.text.trim().isEmpty ? null : _location.text.trim(),
      weather: _weather.isEmpty ? null : _weather,
      progressObserved: _progress > 0 ? _progress : null,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      mediaPaths: _files.map((f) => f.path).toList(),
    );
    await ref.read(inspectionDraftStoreProvider).add(draft);
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectOptionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('New Field Inspection')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Project picker
            projects.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error loading projects: $e'),
              data: (list) => DropdownButtonFormField<ProjectOption>(
                value: _project,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Project'),
                items: list.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                onChanged: (v) => setState(() => _project = v),
              ),
            ),
            const SizedBox(height: 16),

            // GPS section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.gps_fixed, size: 18),
                        const SizedBox(width: 6),
                        const Text('Location', style: TextStyle(fontWeight: FontWeight.w600)),
                        const Spacer(),
                        OutlinedButton.icon(
                          onPressed: _capturingGps ? null : _captureGps,
                          icon: _capturingGps
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.my_location, size: 16),
                          label: const Text('Use my location'),
                        ),
                      ],
                    ),
                    if (_gpsError != null) ...[
                      const SizedBox(height: 8),
                      Text(_gpsError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                    ],
                    if (_position != null) ...[
                      const SizedBox(height: 8),
                      Text('${_position!.latitude.toStringAsFixed(6)}, ${_position!.longitude.toStringAsFixed(6)}'
                          '  (±${_position!.accuracy.toStringAsFixed(0)}m)',
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 160,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(_position!.latitude, _position!.longitude),
                              initialZoom: 16,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'cloud.kadunaelectric.hris',
                              ),
                              MarkerLayer(markers: [
                                Marker(
                                  point: LatLng(_position!.latitude, _position!.longitude),
                                  width: 36, height: 36,
                                  child: const Icon(Icons.location_pin, color: Colors.red, size: 36),
                                ),
                              ]),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    TextField(
                      controller: _location,
                      decoration: const InputDecoration(labelText: 'Site / location name (optional)'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Weather
            DropdownButtonFormField<String>(
              value: _weather.isEmpty ? null : _weather,
              decoration: const InputDecoration(labelText: 'Weather'),
              items: _weathers
                  .map((w) => DropdownMenuItem(value: w, child: Text(w.replaceAll('_', ' '))))
                  .toList(),
              onChanged: (v) => setState(() => _weather = v ?? ''),
            ),
            const SizedBox(height: 16),

            // Progress slider
            Text('Progress observed: $_progress%', style: const TextStyle(fontWeight: FontWeight.w600)),
            Slider(
              value: _progress.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              label: '$_progress%',
              onChanged: (v) => setState(() => _progress = v.round()),
            ),
            const SizedBox(height: 8),

            // Notes
            TextField(
              controller: _notes,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Notes', hintText: 'What did you observe?'),
            ),
            const SizedBox(height: 16),

            // Media
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.attach_file, size: 18),
                        const SizedBox(width: 6),
                        Text('Media (${_files.length})', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickPhoto,
                          icon: const Icon(Icons.camera_alt, size: 16),
                          label: const Text('Camera'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _pickFromGallery,
                          icon: const Icon(Icons.photo_library, size: 16),
                          label: const Text('Gallery'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _pickFiles,
                          icon: const Icon(Icons.insert_drive_file, size: 16),
                          label: const Text('Files'),
                        ),
                      ],
                    ),
                    if (_files.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(_files.length, (i) {
                          final f = _files[i];
                          final ext = f.path.split('.').last.toLowerCase();
                          final isImg = ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext);
                          return Stack(
                            children: [
                              Container(
                                width: 64, height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(6),
                                  image: isImg ? DecorationImage(image: FileImage(f), fit: BoxFit.cover) : null,
                                ),
                                child: isImg ? null : const Center(child: Icon(Icons.description, color: Colors.grey)),
                              ),
                              Positioned(
                                top: -4, right: -4,
                                child: GestureDetector(
                                  onTap: () => setState(() => _files.removeAt(i)),
                                  child: const CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.red,
                                    child: Icon(Icons.close, color: Colors.white, size: 12),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Inspection'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
