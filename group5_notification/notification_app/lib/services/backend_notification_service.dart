import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class BackendNotificationService {

/// Automatically chooses the correct backend URL
/// depending on where the app is running
static String get baseUrl {

// 🌐 Web browser
if (kIsWeb) {
return 'http://localhost:3000';
}

// 🤖 Android Emulator (special loopback address)
if (defaultTargetPlatform == TargetPlatform.android) {
return 'http://10.0.2.2:3000';
}

// 🐧 Linux / Windows / macOS desktop
return 'http://localhost:3000';
}

/// SEND NOTIFICATION TO BACKEND
static Future<bool> send({
required String userId,
required String event,
required Map<String, dynamic> payload,
required String idempotencyKey,
}) async {

final res = await http.post(
Uri.parse('$baseUrl/api/notifications/send'),
headers: {'Content-Type': 'application/json'},
body: jsonEncode({
'userId': userId,
'event': event,
'payload': payload,
'idempotencyKey': idempotencyKey,
}),
);

if (res.statusCode != 200) return false;

final body = jsonDecode(res.body);
return body is Map && body['success'] == true;
}

/// FETCH USER NOTIFICATIONS
static Future<List<dynamic>> fetch(String userId) async {

final res = await http.get(
Uri.parse('$baseUrl/api/notifications/$userId'),
);

if (res.statusCode != 200) {
throw Exception('Fetch failed: ${res.statusCode} ${res.body}');
}

final body = jsonDecode(res.body);
return (body['data'] as List?) ?? [];
}

/// MARK NOTIFICATION AS READ
static Future<void> markAsRead(String id) async {

final res = await http.put(
Uri.parse('$baseUrl/api/notifications/$id/read'),
);

if (res.statusCode != 200) {
throw Exception('Mark read failed: ${res.statusCode} ${res.body}');
}
}
}
