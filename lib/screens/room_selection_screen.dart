import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../services/paystack_webview_service.dart';
import './paystack_webview_screen.dart';
import 'package:hostel_reservation/widgets/app_footer.dart';

class RoomSelectionScreen extends StatefulWidget {
  final String hostelId;

  const RoomSelectionScreen({super.key, required this.hostelId});

  @override
  State<RoomSelectionScreen> createState() => _RoomSelectionScreenState();
}

class _RoomSelectionScreenState extends State<RoomSelectionScreen> {
  Map<String, dynamic>? _selectedRoomData; // Added
  String? _selectedRoomTypeId;
  String? _selectedRoomId;
  Map<String, dynamic>? _selectedRoomTypeData;

  // Use FirebaseAuth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    print('🔐 [RoomSelection] Screen initialized');
    // Listen to auth changes
    _auth.authStateChanges().listen((User? user) {
      if (mounted) {
        print(
          '🔐 [RoomSelection] Auth state changed: ${user != null ? 'Logged in' : 'Logged out'}',
        );
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get current user
    final User? currentUser = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const AppFooter(),
      appBar: AppBar(
        title: const Text('Select Room', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: Colors.black),
        // actions: [
        //   if (currentUser != null)
        //     // Padding(
        //     //   padding: const EdgeInsets.only(right: 16),
        //     //   child: Row(
        //     //     children: [
        //     //       const Icon(Icons.person, size: 20, color: Colors.green),
        //     //       const SizedBox(width: 4),
        //     //       Text(
        //     //         currentUser.email?.split('@')[0] ?? 'User',
        //     //         style: const TextStyle(
        //     //           color: Colors.green,
        //     //           fontSize: 14,
        //     //           fontWeight: FontWeight.w500,
        //     //         ),
        //     //       ),
        //     //     ],
        //     //   ),
        //     // ),
        // ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room Type Selector Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Text(
              'Room Types',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),

          // Room Type Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('room_types')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const SizedBox();
                if (!snapshot.hasData) {
                  return const Center(child: LinearProgressIndicator());
                }

                final types = snapshot.data!.docs;
                if (types.isEmpty) return const SizedBox();

                // Auto-select first room type if none selected
                if (_selectedRoomTypeId == null && types.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _selectedRoomTypeId = types.first.id;
                        _selectedRoomTypeData =
                            types.first.data() as Map<String, dynamic>;
                        print(
                          '🏷️ [RoomSelection] Auto-selected room type: ${_selectedRoomTypeData!['name']}',
                        );
                      });
                    }
                  });
                }

                return DropdownButtonFormField<String>(
                  initialValue: _selectedRoomTypeId,
                  decoration: InputDecoration(
                    labelText: 'Select Room Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: types.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text('${data['name']} (₦${data['price']})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    final selectedDoc = types.firstWhere(
                      (doc) => doc.id == value,
                    );
                    setState(() {
                      _selectedRoomTypeId = value;
                      _selectedRoomTypeData =
                          selectedDoc.data() as Map<String, dynamic>;
                      _selectedRoomId = null;
                      _selectedRoomData = null;
                      print(
                        '🏷️ [RoomSelection] Changed room type to: ${_selectedRoomTypeData!['name']}',
                      );
                    });
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 26),

          // Room List Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Rooms',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Room Grid
          Expanded(
            child: _selectedRoomTypeId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('rooms')
                        .where('hostelId', isEqualTo: widget.hostelId)
                        .where('roomTypeId', isEqualTo: _selectedRoomTypeId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final rooms = snapshot.data!.docs;

                      if (rooms.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.meeting_room_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No rooms found for this type',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // 2 columns
                              childAspectRatio:
                                  0.8, // Adjusted height for button
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: rooms.length,
                        itemBuilder: (context, index) {
                          final room = rooms[index];
                          final data = room.data() as Map<String, dynamic>;
                          final isAvailable = data['isAvailable'] ?? false;
                          final roomName = data['name'] ?? 'Room ${index + 1}';
                          final isSelected = _selectedRoomId == room.id;
                          final capacity =
                              (_selectedRoomTypeData?['capacity'] as num?)
                                  ?.toInt() ??
                              1;

                          return StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('bookings')
                                .where('roomId', isEqualTo: room.id)
                                .where('status', isEqualTo: 'confirmed')
                                .snapshots(),
                            builder: (context, bookingSnapshot) {
                              final bookedSpaces = bookingSnapshot.hasData
                                  ? bookingSnapshot.data!.docs.length
                                  : 0;
                              final remainingSpaces = capacity - bookedSpaces;
                              final isActuallyAvailable =
                                  isAvailable && remainingSpaces > 0;

                              return InkWell(
                                onTap: isActuallyAvailable
                                    ? () {
                                        setState(() {
                                          _selectedRoomId = room.id;
                                          _selectedRoomData = {
                                            ...data,
                                            'id': room.id,
                                            'customPrice': data['customPrice'],
                                          };
                                          print(
                                            '🏠 [RoomSelection] Selected room: $roomName (ID: ${room.id})',
                                          );
                                        });
                                      }
                                    : null,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.green
                                        : (isActuallyAvailable
                                              ? Colors.white
                                              : Colors.grey[100]),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.green
                                          : (isActuallyAvailable
                                                ? Colors.green.shade200
                                                : Colors.grey.shade300),
                                      width: isSelected ? 2.5 : 2,
                                    ),
                                    boxShadow:
                                        isActuallyAvailable && !isSelected
                                        ? [
                                            BoxShadow(
                                              color: Colors.green.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              isActuallyAvailable
                                                  ? Icons.meeting_room
                                                  : Icons.no_meeting_room,
                                              color: isSelected
                                                  ? Colors.white
                                                  : (isActuallyAvailable
                                                        ? Colors.green
                                                        : Colors.grey),
                                              size: 32,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              roomName,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? Colors.white
                                                    : (isActuallyAvailable
                                                          ? Colors.black87
                                                          : Colors.grey),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '$bookedSpaces/$capacity Spaces',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? Colors.white
                                                    : (isActuallyAvailable
                                                          ? Colors.black87
                                                          : Colors.grey),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              isSelected
                                                  ? 'Selected'
                                                  : (isActuallyAvailable
                                                        ? 'Available'
                                                        : 'Full'),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isSelected
                                                    ? Colors.white
                                                    : (isActuallyAvailable
                                                          ? Colors.green
                                                          : Colors.grey),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            if (isActuallyAvailable) ...[
                                              const SizedBox(height: 8),
                                              SizedBox(
                                                height: 32,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    _initiatePayment(
                                                      data,
                                                      room.id,
                                                    );
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: isSelected
                                                        ? Colors.white
                                                        : Colors.green,
                                                    foregroundColor: isSelected
                                                        ? Colors.green
                                                        : Colors.white,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Book (₦${data['customPrice'] ?? _selectedRoomTypeData?['price'] ?? 1000})',
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: List.generate(
                                                5,
                                                (index) => const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),

          // Book Now Button (appears when room is selected)
          if (_selectedRoomId != null &&
              _selectedRoomData != null &&
              _selectedRoomTypeData != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Show user info if logged in
                    // if (currentUser != null) ...[
                    //   Container(
                    //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    //     decoration: BoxDecoration(
                    //       color: Colors.green.shade50,
                    //       borderRadius: BorderRadius.circular(8),
                    //       border: Border.all(color: Colors.green.shade200),
                    //     ),
                    //     child: Row(
                    //       children: [
                    //         const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    //         const SizedBox(width: 8),
                    //         Expanded(
                    //           child: Text(
                    //             'Booking as: ${currentUser.email}',
                    //             style: const TextStyle(
                    //               color: Colors.green,
                    //               fontWeight: FontWeight.w500,
                    //             ),
                    //             overflow: TextOverflow.ellipsis,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    //   const SizedBox(height: 12),
                    // ],
                    ElevatedButton(
                      onPressed: currentUser != null
                          ? () => _initiatePayment(
                              _selectedRoomData!,
                              _selectedRoomId!,
                            )
                          : () => _showLoginRequiredDialog(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentUser != null
                            ? Colors.green
                            : Colors.orange,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        currentUser != null
                            ? 'Book Now - ₦${_selectedRoomData!['customPrice'] ?? _selectedRoomTypeData?['price'] ?? 1000}'
                            : 'Login to Book',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showLoginRequiredDialog() {
    print('🔐 [RoomSelection] Showing login required dialog');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to book a room.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              print('🔐 [RoomSelection] Navigating to sign in screen');
              Navigator.pop(context);
              context.go('/signin');
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Future<void> _initiatePayment(
    Map<String, dynamic> roomData,
    String roomId,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return; // guard
    print(roomData);
    // Get room price (checking for custom override first)
    final dynamic rawPrice =
        roomData['customPrice'] ?? roomData['price'] ?? 1000;

    int price = rawPrice is int
        ? rawPrice
        : (rawPrice is double
              ? rawPrice.toInt()
              : int.tryParse(rawPrice.toString()) ?? 1000);

    // Generate unique reference
    final reference = paystackService.generateReference();

    // Use test email - NO LOGIN REQUIRED
    const testEmail = 'customer@example.com';

    // Navigate to Paystack WebView with user email
    print('🔄 Navigating to Paystack WebView...');
    final paymentSuccessful = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PaystackWebviewScreen(
          email: user.email ?? 'student@futo.edu.ng',
          userId: user.uid,
          amount: price,
          reference: reference,
          roomId: roomId,
          roomName: roomData['name'] ?? 'Room',
          hostelId: widget.hostelId,
          roomTypeId: _selectedRoomTypeId!,
        ),
      ),
    );

    print('✅ [RoomSelection] Payment result: $paymentSuccessful');
    print('==========================================');

    // If payment successful, clear selection and show success
    if (paymentSuccessful == true && mounted) {
      setState(() {
        _selectedRoomId = null;
        _selectedRoomData = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room booked successfully! '),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
