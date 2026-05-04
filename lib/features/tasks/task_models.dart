/// Mirror of the API's TaskResource shape.
class Task {
  Task({
    required this.id,
    required this.title,
    required this.status,
    required this.state,
    required this.priority,
    required this.progressPercent,
    required this.assignees,
    this.description,
    this.projectId,
    this.projectName,
    this.milestoneName,
    this.dueDate,
    this.completedDate,
    this.estimatedHours,
    this.actualHours,
    this.tags = const [],
  });

  final int id;
  final String title;
  final String? description;
  final String status;
  final String state;
  final String priority;
  final int progressPercent;
  final int? projectId;
  final String? projectName;
  final String? milestoneName;
  final String? dueDate;
  final String? completedDate;
  final String? estimatedHours;
  final String? actualHours;
  final List<String> tags;
  final List<TaskAssignee> assignees;

  factory Task.fromJson(Map<String, dynamic> j) => Task(
        id: j['id'] as int,
        title: j['title'] as String,
        description: j['description'] as String?,
        status: j['status'] as String? ?? 'todo',
        state: j['state'] as String? ?? '04_waiting_normal',
        priority: j['priority'] as String? ?? 'medium',
        progressPercent: (j['progress_percent'] as num?)?.toInt() ?? 0,
        projectId: j['project_id'] as int?,
        projectName: (j['project'] as Map?)?['name'] as String?,
        milestoneName: (j['milestone'] as Map?)?['name'] as String?,
        dueDate: j['due_date'] as String?,
        completedDate: j['completed_date'] as String?,
        estimatedHours: j['estimated_hours']?.toString(),
        actualHours: j['actual_hours']?.toString(),
        tags: (j['tags'] as List?)?.cast<String>() ?? const [],
        assignees: (j['assignees'] as List? ?? const [])
            .map((a) => TaskAssignee(id: a['id'] as int, name: a['name'] as String))
            .toList(),
      );
}

class TaskAssignee {
  TaskAssignee({required this.id, required this.name});
  final int id;
  final String name;
}

class TaskState {
  static const backlog = '04_waiting_normal';
  static const inProgress = '01_in_progress';
  static const changesRequested = '02_changes_requested';
  static const approved = '03_approved';
  static const done = '1_done';
  static const cancelled = '1_canceled';

  static const all = [backlog, inProgress, changesRequested, approved, done, cancelled];

  static String label(String s) => switch (s) {
        backlog => 'Backlog',
        inProgress => 'In Progress',
        changesRequested => 'Changes Requested',
        approved => 'Approved',
        done => 'Done',
        cancelled => 'Cancelled',
        _ => s,
      };
}
