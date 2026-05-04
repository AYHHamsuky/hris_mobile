import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';

/// Map an FCM data payload to an in-app deep link path.
String? deepLinkFor(RemoteMessage msg) {
  final data = msg.data;
  final type = data['type']?.toString();

  switch (type) {
    case 'task.assigned':
      final id = data['task_id']?.toString();
      return id != null ? '/tasks/$id' : '/tasks';
    case 'leave.submitted':
    case 'leave.lm_approved':
    case 'leave.lm_rejected':
    case 'leave.approved':
    case 'leave.rejected':
      return '/leave';
    case 'milestone.completed':
      return '/dashboard';
    default:
      return null;
  }
}

void handlePushTap(GoRouter router, RemoteMessage msg) {
  final path = deepLinkFor(msg);
  if (path != null) router.go(path);
}
