import 'package:flutter/material.dart';

import '../../core/widgets/app_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = List.generate(
      5,
      (index) => (
        'Charging reminder',
        'Station ${index + 1} has two slots available.',
        DateTime.now().subtract(Duration(hours: index * 3)),
      ),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              child: ListTile(
                leading: const Icon(Icons.notifications_active),
                title: Text(notification.$1),
                subtitle: Text(notification.$2),
                trailing: Text('${notification.$3.hour}:${notification.$3.minute.toString().padLeft(2, '0')}'),
              ),
            ),
          );
        },
      ),
    );
  }
}
