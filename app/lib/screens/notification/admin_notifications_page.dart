import 'package:flutter/material.dart';

class AdminNotificationsPage extends StatelessWidget {
  const AdminNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> adminNotifications = [
      "New User Registered: ",
      "Meter Added: Building-A Main Meter",
      "System Alert: Database Backup Completed",
      "High Consumption Detected in Block-C",
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Notifications")),
      body: ListView.builder(
        itemCount: adminNotifications.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.notifications, color: Colors.blue),
              title: Text(adminNotifications[index]),
            ),
          );
        },
      ),
    );
  }
}
