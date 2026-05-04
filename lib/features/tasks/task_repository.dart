import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import 'task_models.dart';

class TaskRepository {
  TaskRepository(this._api);
  final ApiClient _api;

  Future<List<Task>> list({String? state, String? priority, int? projectId, String? search}) async {
    final resp = await _api.dio.get('/tasks', queryParameters: {
      if (state != null) 'state': state,
      if (priority != null) 'priority': priority,
      if (projectId != null) 'project_id': projectId,
      if (search != null && search.isNotEmpty) 'search': search,
      'per_page': 50,
    });
    final data = (resp.data['data'] as List).cast<Map<String, dynamic>>();
    return data.map(Task.fromJson).toList();
  }

  Future<Task> show(int id) async {
    final resp = await _api.dio.get('/tasks/$id');
    return Task.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<void> updateState(int id, String state) async {
    await _api.dio.patch('/tasks/$id/state', data: {'state': state});
  }

  Future<void> updateProgress(int id, {int? percent, double? actualHours}) async {
    await _api.dio.patch('/tasks/$id/progress', data: {
      if (percent != null) 'progress_percent': percent,
      if (actualHours != null) 'actual_hours': actualHours,
    });
  }

  Future<void> addComment(int id, String body) async {
    await _api.dio.post('/tasks/$id/comments', data: {'body': body});
  }
}

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.read(apiClientProvider));
});

/// Filter object for the tasks list.
class TaskFilter {
  TaskFilter({this.state, this.priority, this.projectId, this.search});
  final String? state;
  final String? priority;
  final int? projectId;
  final String? search;
}

final tasksProvider = FutureProvider.family<List<Task>, TaskFilter>((ref, filter) async {
  return ref.read(taskRepositoryProvider).list(
        state: filter.state,
        priority: filter.priority,
        projectId: filter.projectId,
        search: filter.search,
      );
});
