import 'dart:convert';
import 'package:http/http.dart' as http;

class SendGridService {
  // Backend base URL (Linux desktop)
  static const String _baseUrl = 'http://localhost:3000';

  Future<bool> sendEmail({
    required String toEmail,
    required String subject,
    required String content,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/api/notifications/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "userId": "email-only", // backend may ignore; better if you pass real uid in metadata
          "event": "account_update",
          "payload": {
            "channel": "email",
            "email": toEmail,
            "title": subject,
            "message": content,
          },
          "idempotencyKey": "email_${toEmail}_$subject"
        }),
      );

      final ok = res.statusCode == 200;
      if (!ok) {
        print('❌ Backend rejected email: ${res.statusCode} ${res.body}');
      }
      return ok;
    } catch (e) {
      print('❌ Email call failed: $e');
      return false;
    }
  }
}
