import 'dart:convert';
import 'package:http/http.dart' as http;

class PaystackWebviewService {

  static const String _secretKey = 'sk_live_6770238bc80d11a2bedcbb03757b33e453f88850'; 
  
  // Initialize transaction and get checkout URL
  Future<String?> initializeTransaction({
    required String email,
    required int amount, // Amount in Naira
    required String reference,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      print('Paystack: Initializing transaction...');
      print('Email: $email');
      print('Amount: ₦$amount');
      print('Reference: $reference');
      
      final response = await http.post(
        Uri.parse('https://api.paystack.co/transaction/initialize'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'amount': 60 * 100, // Convert to kobo
          'reference': reference,
          'currency': 'NGN',
          'metadata': metadata,
          'callback_url': 'https://yourdomain.com/payment-callback', // Update with your domain
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          print('Paystack: Transaction initialized successfully');
          return data['data']['authorization_url'];
        } else {
          print('Paystack: API returned status false: ${data['message']}');
        }
      } else {
        print('Paystack: HTTP Error ${response.statusCode}');
        print('Response: ${response.body}');
      }
      
      return null;
    } catch (e) {
      print('Paystack: Error initializing: $e');
      return null;
    }
  }

  // Verify transaction status
  Future<bool> verifyTransaction(String reference) async {
    try {
      print('Paystack: Verifying transaction: $reference');
      
      final response = await http.get(
        Uri.parse('https://api.paystack.co/transaction/verify/$reference'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final isSuccess = data['data']['status'] == 'success';
        
        if (isSuccess) {
          print('Paystack: Transaction verified: SUCCESS');
        } else {
          print('Paystack: Transaction verified: ${data['data']['status']}');
        }
        
        return isSuccess;
      } else {
        print('Paystack: Verification failed with status ${response.statusCode}');
        print('Response: ${response.body}');
      }
      
      return false;
    } catch (e) {
      print('Paystack: Error verifying: $e');
      return false;
    }
  }

  // Generate unique reference
  String generateReference() {
    final now = DateTime.now();
    return 'PAY_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.millisecondsSinceEpoch}';
  }
}

// Singleton instance
final paystackService = PaystackWebviewService();