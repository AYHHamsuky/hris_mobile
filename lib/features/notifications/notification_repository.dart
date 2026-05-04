import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';

class AppNotification {
  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.deepLink,
  });

  final int id;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final String createdAt;
  final String? deepLink;

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'] as int,
        type: j['type'] as String? ?? 'unknown',
        title: j['title'] as String,
        body: j['body'] as String,
        isRead: j['is_read'] as bool? ?? false,
        createdAt: j['created_at'] as String? ?? '',
        deepLink: j['deep_link'] as String?,
      );
}

class NotificationsResult {
  NotificationsResult({required this.items, required this.unread});
  final List<AppNotification> items;
  final int unread;
}

class NotificationRepository {
  NotificationRepository(this._api);
  final ApiClient _api;

  Future<NotificationsResult> list() async {
    final r = await _api.dio.get('/notifications', queryParameters: {'per_page': 50});
    return NotificationsResult(
      items: (r.data['data'] as List).cast<Map<String, dynamic>>().map(AppNotification.fromJson).toList(),
      unread: (r.data['meta']?['unread'] as int?) ?? 0,
    );
  }

  Future<int> unreadCount() async {
    final r = await _api.dio.get('/notifications/unread-count');
    return (r.data['unread'] as int?) ?? 0;
  }

  Future<void> markRead(int id) async {
    await _api.dio.post('/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await _api.dio.post('/notifications/mark-all-read');
  }

  Future<void> destroy(int id) async {
    await _api.dio.delete('/notifications/$id');
  }
}

final notificationRepoProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.read(apiClientProvider));
});

final notificationsProvider = FutureProvider<NotificationsResult>((ref) async {
  return ref.read(notificationRepoProvider).list();
});

final unreadCountProvider = FutureProvider<int>((ref) async {
  return ref.read(notificationRepoProvider).unreadCount();
});
