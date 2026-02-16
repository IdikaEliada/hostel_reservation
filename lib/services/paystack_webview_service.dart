import 'dart:convert';
import 'package:http/http.dart' as http;

class PaystackWebviewService {
  // 🔴 REPLACE WITH YOUR PAYSTACK SECRET KEY (test key)
  static const String _secretKey = 'sk_test_489b929c2d2846778507771d7f9a09ee5ba38422';
  
  // Initialize transaction and get checkout URL
  Future<String?> initializeTransaction({
    required String email,
    required int amount, // Amount in Naira
    required String reference,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.paystack.co/transaction/initialize'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'amount': amount * 100, // Convert to kobo
          'reference': reference,
          'currency': 'NGN',
          'metadata': metadata,
          'callback_url': 'https://your-app.com/payment-callback',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          return data['data']['authorization_url'];
        }
      }
      
      print('Paystack init error: ${response.body}');
      return null;
    } catch (e) {
      print('Error initializing Paystack: $e');
      return null;
    }
  }

  // Verify transaction status
  Future<bool> verifyTransaction(String reference) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.paystack.co/transaction/verify/$reference'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['status'] == 'success';
      }
      
      return false;
    } catch (e) {
      print('Error verifying Paystack: $e');
      return false;
    }
  }

  // Generate unique reference
  String generateReference() {
    final now = DateTime.now();
    return 'TEST_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.millisecondsSinceEpoch}';
  }
}

// Singleton instance
final paystackService = PaystackWebviewService();