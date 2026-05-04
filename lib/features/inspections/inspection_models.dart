class Inspection {
  Inspection({
    required this.id,
    required this.inspectedAt,
    required this.media,
    this.projectName,
    this.locationName,
    this.latitude,
    this.longitude,
    this.weather,
    this.progressObserved,
    this.notes,
    this.osmUrl,
  });

  final int id;
  final String inspectedAt;
  final List<InspectionMedia> media;
  final String? projectName;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final String? weather;
  final int? progressObserved;
  final String? notes;
  final String? osmUrl;

  factory Inspection.fromJson(Map<String, dynamic> j) => Inspection(
        id: j['id'] as int,
        inspectedAt: j['inspected_at'] as String? ?? '',
        projectName: (j['project'] as Map?)?['name'] as String?,
        locationName: j['location_name'] as String?,
        latitude: (j['latitude'] as num?)?.toDouble(),
        longitude: (j['longitude'] as num?)?.toDouble(),
        weather: j['weather'] as String?,
        progressObserved: j['progress_observed'] as int?,
        notes: j['notes'] as String?,
        osmUrl: j['osm_url'] as String?,
        media: (j['media'] as List? ?? const [])
            .cast<Map<String, dynamic>>()
            .map(InspectionMedia.fromJson)
            .toList(),
      );
}

class InspectionMedia {
  InspectionMedia({required this.id, required this.kind, required this.url, required this.originalName});
  final int id;
  final String kind; // photo, video, audio, document
  final String url;
  final String originalName;

  factory InspectionMedia.fromJson(Map<String, dynamic> j) => InspectionMedia(
        id: j['id'] as int,
        kind: j['kind'] as String,
        url: j['url'] as String,
        originalName: j['original_name'] as String,
      );
}

class ProjectOption {
  ProjectOption({required this.id, required this.name});
  final int id;
  final String name;

  factory ProjectOption.fromJson(Map<String, dynamic> j) =>
      ProjectOption(id: j['id'] as int, name: j['name'] as String);
}
