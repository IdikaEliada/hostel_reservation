import 'package:flutter/material.dart';
import '../services/backend_notification_service.dart';

class NotificationCenter extends StatefulWidget {
const NotificationCenter({super.key});

@override
State<NotificationCenter> createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter> {
final _userController = TextEditingController(text: "test-user-001");

bool _loading = false;
String _result = "";

Future<void> _sendTestNotification() async {
setState(() {
_loading = true;
_result = "";
});

final ok = await BackendNotificationService.send(
userId: _userController.text.trim(),
event: "booking_confirmation",
payload: {
"title": "Flutter Test",
"message": "If you see this → Flutter ↔ Backend ↔ Firebase works 🎉",
"channel": ["in_app"]
},
idempotencyKey: DateTime.now().millisecondsSinceEpoch.toString(),
);

setState(() {
_loading = false;
_result = ok ? "✅ Sent successfully" : "❌ Failed to send";
});
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text("Notification Tester")),
body: Padding(
padding: const EdgeInsets.all(20),
child: Column(
children: [
TextField(
controller: _userController,
decoration: const InputDecoration(labelText: "User ID"),
),
const SizedBox(height: 20),

ElevatedButton(
onPressed: _loading ? null : _sendTestNotification,
child: _loading
? const CircularProgressIndicator()
: const Text("Send Test Notification"),
),

const SizedBox(height: 20),
Text(_result, style: const TextStyle(fontSize: 16)),
],
),
),
);
}
}
