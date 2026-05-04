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

/// Returned by GET /tasks/{id} — task plus comments + attachments + (eager) subtasks.
class TaskDetail {
  TaskDetail({required this.task, this.comments = const [], this.attachments = const []});
  final Task task;
  final List<TaskComment> comments;
  final List<TaskAttachmentFile> attachments;

  factory TaskDetail.fromJson(Map<String, dynamic> root) {
    return TaskDetail(
      task: Task.fromJson(root['data'] as Map<String, dynamic>),
      comments: (root['comments'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(TaskComment.fromJson)
          .toList(),
      attachments: (root['attachments'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(TaskAttachmentFile.fromJson)
          .toList(),
    );
  }
}

class TaskComment {
  TaskComment({required this.id, required this.body, required this.userName, required this.createdAt});
  final int id;
  final String body;
  final String userName;
  final String createdAt;

  factory TaskComment.fromJson(Map<String, dynamic> j) => TaskComment(
        id: j['id'] as int,
        body: j['body'] as String,
        userName: (j['user'] as Map?)?['name'] as String? ?? 'Unknown',
        createdAt: j['created_at'] as String? ?? '',
      );
}

class TaskAttachmentFile {
  TaskAttachmentFile({required this.id, required this.name, required this.url, this.mime, this.sizeBytes});
  final int id;
  final String name;
  final String url;
  final String? mime;
  final int? sizeBytes;

  factory TaskAttachmentFile.fromJson(Map<String, dynamic> j) => TaskAttachmentFile(
        id: j['id'] as int,
        name: j['name'] as String? ?? 'file',
        url: j['url'] as String? ?? '',
        mime: j['mime'] as String?,
        sizeBytes: j['size_bytes'] as int?,
      );
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
