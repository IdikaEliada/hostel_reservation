import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/paystack_webview_service.dart';
import 'package:hostel_reservation/widgets/app_footer.dart';

// IMPORTANT: Add these imports for platform initialization
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class PaystackWebviewScreen extends StatefulWidget {
  final String email;
  final String userId;
  final int amount;
  final String reference;
  final String roomId;
  final String roomName;
  final String hostelId;
  final String roomTypeId;

  const PaystackWebviewScreen({
    super.key,
    required this.email,
    required this.userId,
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
    print('[Paystack] ========== PAYMENT INITIALIZED ==========');
    print(' Email: ${widget.email}');
    print(' User ID: ${widget.userId}');
    print(' Amount: ₦${widget.amount}');
    print('Reference: ${widget.reference}');
    print(' Room ID: ${widget.roomId}');
    print(' Room Name: ${widget.roomName}');
    print(' Hostel ID: ${widget.hostelId}');
    print(' Room Type ID: ${widget.roomTypeId}');
    print('==========================================');

    _initializePayment();
  }

  Future<void> _initializePayment() async {
    print(' [Paystack] Initializing payment with Paystack API...');

    // Initialize transaction with Paystack using real user email
    final url = await paystackService.initializeTransaction(
      email: widget.email,
      amount: widget.amount,
      reference: widget.reference,
      metadata: {
        'room_id': widget.roomId,
        'room_name': widget.roomName,
        'hostel_id': widget.hostelId,
        'room_type_id': widget.roomTypeId,
        'user_id': widget.userId,
      },
    );

    if (url != null && mounted) {
      print(' [Paystack] Payment initialized successfully!');
      print('🔗 Authorization URL: $url');

      setState(() {
        _authorizationUrl = url;
      });

      _initWebViewController(url);
    } else {
      print(' [Paystack] Failed to initialize payment - URL is null');
      _showError('Failed to initialize payment');
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _initWebViewController(String url) {
    print(' [WebView] Initializing WebView controller...');

    // Create platform-specific WebView implementations
    late final PlatformWebViewControllerCreationParams params;

    // Set platform instance based on platform
    if (Theme.of(context).platform == TargetPlatform.android) {
      print('📱 [Platform] Android detected');
      WebViewPlatform.instance = AndroidWebViewPlatform();
    } else {
      print('📱 [Platform] iOS detected');
      WebViewPlatform.instance = WebKitWebViewPlatform();
    }

    params = const PlatformWebViewControllerCreationParams();

    final controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print(' [WebView] Page started loading: $url');
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            print(' [WebView] Page finished loading: $url');
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            print(' [WebView] Navigation request: ${request.url}');

            // Check if payment was successful
            if (request.url.contains('success') ||
                request.url.contains('paid') ||
                request.url.contains('callback') ||
                request.url.contains('reference')) {
              print(' [Paystack] Payment success detected in URL!');
              _handlePaymentSuccess();
              return NavigationDecision.prevent;
            }

            // Check if payment was cancelled
            if (request.url.contains('cancel')) {
              print(' [Paystack] Payment cancelled detected in URL');
              _handlePaymentCancelled();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      );

    // Load the URL
    print(' [WebView] Loading URL: $url');
    controller.loadRequest(Uri.parse(url));

    // Set the controller
    _controller = controller;

    // Update UI
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
    print(' [WebView] WebView controller initialized');
  }

  Future<void> _handlePaymentSuccess() async {
    if (_paymentComplete) {
      print(' [Paystack] Payment already completed, skipping...');
      return;
    }

    print(' [Paystack] ========== PAYMENT SUCCESS DETECTED ==========');
    print('Reference: ${widget.reference}');

    setState(() {
      _paymentComplete = true;
    });

    try {
      // Verify transaction with Paystack
      print(' [Paystack] Verifying transaction with Paystack...');
      final isSuccessful = await paystackService.verifyTransaction(
        widget.reference,
      );

      print(' [Paystack] Verification result: $isSuccessful');

      if (!isSuccessful) {
        throw Exception('Payment verification failed');
      }

      // Get room capacity
      print(' [Firestore] Checking room capacity...');
      final roomTypeDoc = await FirebaseFirestore.instance
          .collection('room_types')
          .doc(widget.roomTypeId)
          .get();
      final capacity = (roomTypeDoc.data()?['capacity'] as num?)?.toInt() ?? 1;

      // Get current active bookings
      final bookingsQuery = await FirebaseFirestore.instance
          .collection('bookings')
          .where('roomId', isEqualTo: widget.roomId)
          .where('status', isEqualTo: 'confirmed')
          .get();

      final currentBookings = bookingsQuery.docs.length;
      final isNowFull = (currentBookings + 1) >= capacity;

      print(
        ' [Firestore] Capacity: $capacity, Current Bookings: $currentBookings',
      );
      print(' [Firestore] Updating room availability...');
      print('   Room ID: ${widget.roomId}');
      print('   Setting isAvailable: ${!isNowFull}');

      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomId)
          .update({
            'isAvailable': !isNowFull,
            'bookedAt': FieldValue.serverTimestamp(),
            'bookedBy': widget.userId,
            'bookedByEmail': widget.email,
            'paymentReference': widget.reference,
          });

      print(' [Firestore] Room updated successfully');

      // Create booking record with real user info
      print(' [Firestore] Creating booking record...');
      final bookingRef = await FirebaseFirestore.instance
          .collection('bookings')
          .add({
            'userId': widget.userId,
            'userEmail': widget.email,
            'hostelId': widget.hostelId,
            'roomId': widget.roomId,
            'roomName': widget.roomName,
            'roomTypeId': widget.roomTypeId,
            'amount': widget.amount,
            'paymentReference': widget.reference,
            'paymentMethod': 'Paystack',
            'status': 'confirmed',
            'isGuestBooking': false,
            'createdAt': FieldValue.serverTimestamp(),
          });

      print(' [Firestore] Booking created successfully!');
      print('   Booking ID: ${bookingRef.id}');
      print('==========================================');

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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('Room: ${widget.roomName}'),
              Text('Email: ${widget.email}'),
              Text('Ref: ${widget.reference.substring(0, 8)}...'),
              const SizedBox(height: 10),
              const Text('Your room has been booked successfully.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                print('👆 [UI] User clicked OK on success dialog');
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print(' [ERROR] Error in payment success handling: $e');
      print('   Stack trace: ${StackTrace.current}');
      _showError('Payment successful but booking failed: ${e.toString()}');

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  void _handlePaymentCancelled() {
    print(' [Paystack] Payment cancelled by user');

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
    print(' [ERROR] $message');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter(),
      appBar: AppBar(
        title: const Text('Paystack Payment'),
        elevation: 0,
        backgroundColor: Colors.green,
        actions: [
          if (_authorizationUrl != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                print(' [UI] User clicked refresh button');
                _controller.reload();
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          if (_authorizationUrl != null) WebViewWidget(controller: _controller),
          if (_isLoading || _authorizationUrl == null)
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
