import 'package:flutter/material.dart';

import '../../core/widgets/app_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_Notification> _notifications = [
    _Notification(
      title: 'Charging reminder',
      message: 'Station Downtown Hub has two slots available.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      type: NotificationType.charging,
    ),
    _Notification(
      title: 'Software update',
      message: 'New cabin climate automation arriving tonight.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      type: NotificationType.system,
    ),
    _Notification(
      title: 'Maintenance',
      message: 'Tire rotation due in 200 km. Tap to schedule.',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      type: NotificationType.maintenance,
    ),
    _Notification(
      title: 'Charging complete',
      message: 'BMW i4 reached 100%. Please unplug soon.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.charging,
    ),
  ];
  NotificationType? filter;
  final Set<int> read = {};

  @override
  Widget build(BuildContext context) {
    final filtered = filter == null
        ? _notifications
        : _notifications.where((item) => item.type == filter).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () => setState(() => read.addAll(List.generate(_notifications.length, (index) => index))),
            tooltip: 'Mark all as read',
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: filter == null,
                onSelected: (_) => setState(() => filter = null),
              ),
              ...NotificationType.values.map(
                (type) => ChoiceChip(
                  label: Text(type.label),
                  selected: filter == type,
                  onSelected: (_) => setState(() => filter = type),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            const Center(child: Text('No notifications in this category yet.'))
          else
            ...filtered.map(
              (notification) {
                final index = _notifications.indexOf(notification);
                final isRead = read.contains(index);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    child: ListTile(
                      leading: Icon(notification.type.icon),
                      title: Text(notification.title,
                          style: TextStyle(
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          )),
                      subtitle: Text(notification.message),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_formatTime(notification.createdAt)),
                          const SizedBox(height: 4),
                          IconButton(
                            icon: Icon(
                              isRead ? Icons.mark_email_read : Icons.mark_email_unread,
                            ),
                            onPressed: () => setState(() {
                              if (isRead) {
                                read.remove(index);
                              } else {
                                read.add(index);
                              }
                            }),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    return '${difference.inDays}d ago';
  }
}

class _Notification {
  _Notification({
    required this.title,
    required this.message,
    required this.createdAt,
    required this.type,
  });

  final String title;
  final String message;
  final DateTime createdAt;
  final NotificationType type;
}

enum NotificationType { charging, system, maintenance }

extension on NotificationType {
  IconData get icon {
    switch (this) {
      case NotificationType.charging:
        return Icons.bolt;
      case NotificationType.system:
        return Icons.settings_suggest;
      case NotificationType.maintenance:
        return Icons.build_circle;
    }
  }

  String get label {
    switch (this) {
      case NotificationType.charging:
        return 'Charging';
      case NotificationType.system:
        return 'System';
      case NotificationType.maintenance:
        return 'Maintenance';
    }
  }
}
