import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/paystack_webview_service.dart';
import './paystack_webview_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        title: const Text('Select Room', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: Colors.black),
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
                if (!snapshot.hasData)
                  return const Center(child: LinearProgressIndicator());

                final types = snapshot.data!.docs;
                if (types.isEmpty) return const SizedBox();

                // Auto-select first room type if none selected
                if (_selectedRoomTypeId == null && types.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _selectedRoomTypeId = types.first.id;
                      });
                    }
                  });
                }

                return DropdownButtonFormField<String>(
                  value: _selectedRoomTypeId,
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
                    setState(() {
                      _selectedRoomTypeId = value;
                      _selectedRoomId =
                          null; // Reset room selection on type change
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
                              childAspectRatio: 1.5,
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

                          return InkWell(
                            onTap: isAvailable
                                ? () {
                                    setState(() {
                                      _selectedRoomId = room.id;
                                    });
                                  }
                                : null,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.green
                                    : (isAvailable
                                          ? Colors.white
                                          : Colors.grey[100]),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.green
                                      : (isAvailable
                                            ? Colors.green.shade200
                                            : Colors.grey.shade300),
                                  width: isSelected ? 2.5 : 2,
                                ),
                                boxShadow: isAvailable && !isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.1),
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
                                          isAvailable
                                              ? Icons.meeting_room
                                              : Icons.no_meeting_room,
                                          color: isSelected
                                              ? Colors.white
                                              : (isAvailable
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
                                                : (isAvailable
                                                      ? Colors.black87
                                                      : Colors.grey),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          isSelected
                                              ? 'Selected'
                                              : (isAvailable
                                                    ? 'Available'
                                                    : 'Occupied'),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isSelected
                                                ? Colors.white
                                                : (isAvailable
                                                      ? Colors.green
                                                      : Colors.grey),
                                            fontWeight: FontWeight.w500,
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
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _initiatePayment(
    Map<String, dynamic> roomData,
    String roomId,
  ) async {
    print(roomData);
    // Get room price
    int price = roomData['price'] is int
        ? roomData['price']
        : int.tryParse(roomData['price'].toString()) ?? 1000;

    // Generate unique reference
    final reference = paystackService.generateReference();

    // Use test email - NO LOGIN REQUIRED
    const testEmail = 'customer@example.com';

    // Navigate to Paystack WebView
    final paymentSuccessful = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PaystackWebviewScreen(
          email: testEmail,
          amount: price,
          reference: reference,
          roomId: roomId,
          roomName: roomData['name'] ?? 'Room',
          hostelId: widget.hostelId,
          roomTypeId: _selectedRoomTypeId!,
        ),
      ),
    );

    // If payment successful, clear selection and show success
    if (paymentSuccessful == true && mounted) {
      setState(() {
        _selectedRoomId = null;
        //_selectedRoomData = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room booked successfully! 🎉'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
