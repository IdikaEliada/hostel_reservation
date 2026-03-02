
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notification_model.dart';
import '../screens/notification_detail.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const NotificationTile({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    // Icon based on type
    IconData icon;
    Color color;

    switch (notification.type) {
      case 'payment':
        icon = Icons.payment;
        color = Colors.green;
        break;
      case 'booking':
        icon = Icons.hotel;
        color = Colors.blue;
        break;
      case 'auth':
        icon = Icons.security;
        color = Colors.orange;
        break;
      case 'reminder':
        icon = Icons.alarm;
        color = Colors.purple;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.grey;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('MMM d, h:mm a').format(notification.createdAt),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      trailing: !notification.isRead
          ? const Icon(Icons.circle, color: Colors.blue, size: 12)
          : null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NotificationDetail(notification: notification),
          ),
        );
      },
    );
  }
}
