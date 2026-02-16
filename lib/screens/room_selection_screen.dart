import 'package:flutter/material.dart';
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
  String? _selectedRoomTypeId;
  String? _selectedRoomId;
  Map<String, dynamic>? _selectedRoomData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Room')),
      body: Column(
        children: [
          // Room Type Selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('room_types')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                if (!snapshot.hasData) return const LinearProgressIndicator();

                final types = snapshot.data!.docs;
                if (types.isEmpty) return const Text('No room types found');

                return DropdownButtonFormField<String>(
                  value: _selectedRoomTypeId,
                  decoration: const InputDecoration(
                    labelText: 'Select Room Type',
                    border: OutlineInputBorder(),
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
                      _selectedRoomId = null;
                      _selectedRoomData = null;
                    });
                  },
                );
              },
            ),
          ),

          // Room List based on selection
          Expanded(
            child: _selectedRoomTypeId == null
                ? const Center(child: Text('Please select a room type'))
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
                        return const Center(
                          child: Text('No rooms found for this type.'),
                        );
                      }

                      return ListView.builder(
                        itemCount: rooms.length,
                        itemBuilder: (context, index) {
                          final room = rooms[index];
                          final data = room.data() as Map<String, dynamic>;
                          final isAvailable = data['isAvailable'] ?? false;
                          final isSelected = _selectedRoomId == room.id;

                          return Card(
                            color: Colors.green,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    data['name'] ?? 'Room',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    isAvailable ? 'Available' : 'Occupied',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  trailing: Icon(
                                    isAvailable
                                        ? Icons.check_circle_outline
                                        : Icons.block,
                                    color: isAvailable
                                        ? Colors.white
                                        : Colors.red[100],
                                  ),
                                  onTap: isAvailable
                                      ? () {
                                          setState(() {
                                            if (isSelected) {
                                              _selectedRoomId = null;
                                              _selectedRoomData = null;
                                            } else {
                                              _selectedRoomId = room.id;
                                              _selectedRoomData = {
                                                'id': room.id,
                                                ...data,
                                              };
                                            }
                                          });
                                        }
                                      : null,
                                ),
                                // BOOK NOW BUTTON
                                if (isAvailable && isSelected)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      right: 16,
                                      bottom: 16,
                                    ),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.green,
                                          elevation: 2,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                        ),
                                        onPressed: () => _initiatePayment(data, room.id),
                                        child: const Text(
                                          'BOOK NOW',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
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

  Future<void> _initiatePayment(Map<String, dynamic> roomData, String roomId) async {
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
        _selectedRoomData = null;
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