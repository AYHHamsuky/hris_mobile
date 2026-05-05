import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';

/// Map an FCM data payload to an in-app deep link path.
String? deepLinkFor(RemoteMessage msg) {
  final data = msg.data;

  // Backend now sends a `deep_link` field directly — prefer that when present.
  final explicit = data['deep_link']?.toString();
  if (explicit != null && explicit.isNotEmpty) return explicit;

  final type = data['type']?.toString();
  switch (type) {
    case 'task.assigned':
      final id = data['task_id']?.toString();
      return id != null ? '/tasks/$id' : '/tasks';
    case 'leave.submitted':
      return '/leave/team';
    case 'leave.lm_approved':
    case 'leave.lm_rejected':
    case 'leave.approved':
    case 'leave.rejected':
      return '/leave';
    case 'milestone.completed':
      final pid = data['project_id']?.toString();
      return pid != null ? '/projects/$pid' : '/dashboard';
    case 'appraisal.approved':
    case 'appraisal.rejected':
    case 'appraisal.updated':
      final id = data['review_id']?.toString();
      return id != null ? '/appraisals/$id' : '/appraisals';
    default:
      return '/notifications';
  }
}

void handlePushTap(GoRouter router, RemoteMessage msg) {
  final path = deepLinkFor(msg);
  if (path != null) router.go(path);
}
