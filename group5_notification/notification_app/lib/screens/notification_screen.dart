import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationScreen extends StatefulWidget {
final String userId;

const NotificationScreen({super.key, required this.userId});

@override
State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Notifications'),
centerTitle: true,
),
body: StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
.collection('notifications')
.where('userId', isEqualTo: widget.userId)
// ✅ channel is List<String> now, so use arrayContains
.where('channel', arrayContains: 'in_app')
.orderBy('createdAt', descending: true)
.snapshots(),
builder: (context, snapshot) {
if (snapshot.hasError) {
return Center(child: Text('Error: ${snapshot.error}'));
}

if (snapshot.connectionState == ConnectionState.waiting) {
return const Center(child: CircularProgressIndicator());
}

final docs = snapshot.data?.docs ?? [];

if (docs.isEmpty) {
return const Center(child: Text('No notifications yet.'));
}

return ListView.builder(
itemCount: docs.length,
itemBuilder: (context, index) {
final model = NotificationModel.fromFirestore(docs[index]);
return _buildNotificationTile(model);
},
);
},
),
);
}

Widget _buildNotificationTile(NotificationModel n) {
IconData icon;
Color color;

switch (n.type) {
case 'PAYMENT_SUCCESS':
icon = Icons.check_circle;
color = Colors.green;
break;
case 'PAYMENT_FAILED':
icon = Icons.error;
color = Colors.red;
break;
case 'BOOKING_CONFIRMED':
icon = Icons.calendar_today;
color = Colors.blue;
break;
case 'BOOKING_CANCELLED':
icon = Icons.event_busy;
color = Colors.orange;
break;
case 'password_changed':
case 'PASSWORD_CHANGED':
icon = Icons.lock_reset;
color = Colors.purple;
break;
case 'security_alert':
case 'SECURITY_ALERT':
icon = Icons.security;
color = Colors.redAccent;
break;
case 'user_signup':
case 'USER_SIGNUP':
icon = Icons.celebration;
color = Colors.amber;
break;
default:
icon = Icons.notifications;
color = Colors.grey;
}

return Card(
margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
elevation: n.isRead ? 0 : 2,
color: n.isRead ? Colors.white : const Color(0xFFF5F9FF),
child: InkWell(
onTap: () async {
if (!n.isRead) {
await FirebaseFirestore.instance
.collection('notifications')
.doc(n.id)
.update({'isRead': true});
}
},
child: Padding(
padding: const EdgeInsets.all(12.0),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
CircleAvatar(
backgroundColor: color.withOpacity(0.1),
child: Icon(icon, color: color),
),
const SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Expanded(
child: Text(
n.title,
style: TextStyle(
fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
fontSize: 16,
),
),
),
if (!n.isRead)
Container(
width: 8,
height: 8,
decoration: const BoxDecoration(
color: Colors.blue,
shape: BoxShape.circle,
),
),
],
),
const SizedBox(height: 4),
Text(
n.message,
style: TextStyle(
color: Colors.grey[700],
fontSize: 14,
),
),
const SizedBox(height: 8),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text(
_formatDate(n.createdAt),
style: TextStyle(color: Colors.grey[500], fontSize: 12),
),
if (n.status == 'sent')
const Icon(Icons.check_circle, size: 14, color: Colors.green),
],
),
],
),
),
],
),
),
),
);
}

String _formatDate(DateTime date) {
final now = DateTime.now();
final difference = now.difference(date);

if (difference.inDays == 0) {
if (difference.inHours == 0) {
return '${difference.inMinutes}m ago';
}
return '${difference.inHours}h ago';
} else if (difference.inDays < 7) {
return '${difference.inDays}d ago';
} else {
return '${date.day}/${date.month}/${date.year}';
}
}
}


