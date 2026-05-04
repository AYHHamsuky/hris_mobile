import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart';
import 'notification_repository.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  IconData _iconFor(String type) {
    if (type.startsWith('task.')) return Icons.task_alt;
    if (type.startsWith('leave.')) return Icons.calendar_month;
    if (type.startsWith('milestone.')) return Icons.flag_outlined;
    return Icons.notifications;
  }

  Color _colorFor(String type) {
    if (type.startsWith('task.')) return Colors.blue;
    if (type.startsWith('leave.')) return Colors.green;
    if (type.startsWith('milestone.')) return Colors.purple;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            tooltip: 'Mark all read',
            icon: const Icon(Icons.done_all),
            onPressed: () async {
              try {
                await ref.read(notificationRepoProvider).markAllRead();
                ref.invalidate(notificationsProvider);
                ref.invalidate(unreadCountProvider);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ApiClient.describeError(e))));
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(notificationsProvider);
              ref.invalidate(unreadCountProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(notificationsProvider);
          ref.invalidate(unreadCountProvider);
        },
        child: result.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(ApiClient.describeError(e))),
          data: (res) {
            if (res.items.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(32),
                children: const [
                  Icon(Icons.notifications_none, size: 64, color: Colors.black26),
                  SizedBox(height: 12),
                  Text("You're all caught up.", textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: res.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => _NotificationTile(item: res.items[i], onTap: () async {
                try {
                  await ref.read(notificationRepoProvider).markRead(res.items[i].id);
                  ref.invalidate(notificationsProvider);
                  ref.invalidate(unreadCountProvider);
                } catch (_) {}
                final link = res.items[i].deepLink;
                if (link != null && link.isNotEmpty && context.mounted) {
                  context.push(link);
                }
              }),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.onTap});
  final AppNotification item;
  final VoidCallback onTap;

  IconData _iconFor() {
    if (item.type.startsWith('task.')) return Icons.task_alt;
    if (item.type.startsWith('leave.')) return Icons.calendar_month;
    if (item.type.startsWith('milestone.')) return Icons.flag_outlined;
    return Icons.notifications;
  }

  Color _colorFor() {
    if (item.type.startsWith('task.')) return Colors.blue;
    if (item.type.startsWith('leave.')) return Colors.green;
    if (item.type.startsWith('milestone.')) return Colors.purple;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: item.isRead ? null : Colors.blue.shade50,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: _colorFor().withValues(alpha: 0.15),
              child: Icon(_iconFor(), color: _colorFor(), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(item.body, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(item.createdAt.split('T').first,
                      style: const TextStyle(fontSize: 10, color: Colors.black45)),
                ],
              ),
            ),
            if (!item.isRead)
              Container(
                width: 8, height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}
