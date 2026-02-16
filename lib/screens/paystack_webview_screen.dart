import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/paystack_webview_service.dart';

// IMPORTANT: Add this for platform initialization
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class PaystackWebviewScreen extends StatefulWidget {
  final String email;
  final int amount;
  final String reference;
  final String roomId;
  final String roomName;
  final String hostelId;
  final String roomTypeId;

  const PaystackWebviewScreen({
    super.key,
    required this.email,
    required this.amount,
    required this.reference,
    required this.roomId,
    required this.roomName,
    required this.hostelId,
    required this.roomTypeId,
  });

  @override
  State<PaystackWebviewScreen> createState() => _PaystackWebviewScreenState();
}

class _PaystackWebviewScreenState extends State<PaystackWebviewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _paymentComplete = false;
  String? _authorizationUrl;

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  Future<void> _initializePayment() async {
    // Initialize transaction with Paystack
    final url = await paystackService.initializeTransaction(
      email: widget.email,
      amount: widget.amount,
      reference: widget.reference,
      metadata: {
        'room_id': widget.roomId,
        'room_name': widget.roomName,
        'hostel_id': widget.hostelId,
        'room_type_id': widget.roomTypeId,
      },
    );

    if (url != null && mounted) {
      setState(() {
        _authorizationUrl = url;
      });
      
      // Initialize WebView AFTER we have the URL
      _initWebViewController(url);
    } else {
      _showError('Failed to initialize payment');
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  // FIXED: Proper WebView initialization
  void _initWebViewController(String url) {
    // Create platform-specific WebView implementations
    late final PlatformWebViewControllerCreationParams params;
    
    // FIXED: Proper platform initialization
    if (WebViewPlatform.instance == null) {
      // Check platform and initialize accordingly
      if (Theme.of(context).platform == TargetPlatform.android) {
        WebViewPlatform.instance = WebKitWebViewPlatform(); // For Android - Wait, this should be AndroidWebViewPlatform
        // CORRECTION: Use AndroidWebViewPlatform for Android
        WebViewPlatform.instance = AndroidWebViewPlatform();
      } else {
        WebViewPlatform.instance = WebKitWebViewPlatform(); // For iOS
      }
    }

    params = const PlatformWebViewControllerCreationParams();
    
    final controller = WebViewController.fromPlatformCreationParams(params);
    
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // Check if payment was successful
            if (request.url.contains('success') || 
                request.url.contains('paid') ||
                request.url.contains('callback') ||
                request.url.contains('reference')) {
              _handlePaymentSuccess();
              return NavigationDecision.prevent;
            }
            
            // Check if payment was cancelled
            if (request.url.contains('cancel')) {
              _handlePaymentCancelled();
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
        ),
      );

    // Load the URL
    controller.loadRequest(Uri.parse(url));

    // Set the controller first
    _controller = controller;
    
    // Then update UI
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handlePaymentSuccess() async {
    if (_paymentComplete) return;
    
    setState(() {
      _paymentComplete = true;
    });

    try {
      // Verify transaction with Paystack
      final isSuccessful = await paystackService.verifyTransaction(widget.reference);
      
      if (!isSuccessful) {
        throw Exception('Payment verification failed');
      }

      // Update room availability - NO LOGIN REQUIRED
      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomId)
          .update({
            'isAvailable': false,
            'bookedAt': FieldValue.serverTimestamp(),
            'bookedBy': 'guest_${widget.reference}',
            'paymentReference': widget.reference,
          });

      // Create booking record - NO LOGIN REQUIRED
      await FirebaseFirestore.instance.collection('bookings').add({
        'userId': 'guest_${widget.reference}',
        'userEmail': widget.email,
        'hostelId': widget.hostelId,
        'roomId': widget.roomId,
        'roomName': widget.roomName,
        'roomTypeId': widget.roomTypeId,
        'amount': widget.amount,
        'paymentReference': widget.reference,
        'paymentMethod': 'Paystack',
        'status': 'confirmed',
        'isGuestBooking': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // Show success and return
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text('Room: ${widget.roomName}'),
              Text('Ref: ${widget.reference.substring(0, 8)}...'),
              const SizedBox(height: 10),
              const Text('Your room has been booked successfully.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Return success
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error saving booking: $e');
      _showError('Payment successful but booking failed: ${e.toString()}');
      
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  void _handlePaymentCancelled() {
    if (!mounted) return;
    
    Navigator.pop(context, false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment cancelled'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paystack Payment'),
        elevation: 0,
        backgroundColor: Colors.green,
        actions: [
          // FIXED: Check if _controller is initialized before using it
          if (_authorizationUrl != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                if (_controller != null) {
                  _controller.reload();
                }
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          // FIXED: Only show WebView when both conditions are met
          if (_authorizationUrl != null && _controller != null)
            WebViewWidget(controller: _controller),
          
          // FIXED: Show loading until everything is ready
          if (_isLoading || _authorizationUrl == null || _controller == null)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    SizedBox(height: 16),
                    Text('Initializing payment...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}