import 'dart:convert';
import 'package:http/http.dart' as http;

class SmsServiceTermii {
  static const String _baseUrl = 'http://localhost:3000';

  Future<bool> sendSms({
    required String toPhone,
    required String message,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/api/notifications/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "userId": "sms-only",
          "event": "security_alert",
          "payload": {
            "channel": "sms",
            "phoneNumber": toPhone,
            "message": message
          },
          "idempotencyKey": "sms_${toPhone}_${message.hashCode}"
        }),
      );

      final ok = res.statusCode == 200;
      if (!ok) {
        print('❌ Backend rejected sms: ${res.statusCode} ${res.body}');
      }
      return ok;
    } catch (e) {
      print('❌ SMS call failed: $e');
      return false;
    }
  }
}
