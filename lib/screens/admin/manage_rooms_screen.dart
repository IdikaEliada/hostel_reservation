import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_modal.dart';

class ManageRoomsScreen extends StatefulWidget {
  final String? hostelId;

  const ManageRoomsScreen({super.key, this.hostelId});

  @override
  State<ManageRoomsScreen> createState() => _ManageRoomsScreenState();
}

class _ManageRoomsScreenState extends State<ManageRoomsScreen> {
  Map<String, String> _hostelNames = {};
  Map<String, Map<String, dynamic>> _roomTypeData = {};
  bool _isLoadingMetadata = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchMetadata();
  }

  Future<void> _fetchMetadata() async {
    try {
      final hostelsSnapshot = await FirebaseFirestore.instance
          .collection('hostels')
          .get();
      final roomTypesSnapshot = await FirebaseFirestore.instance
          .collection('room_types')
          .get();

      final hostelMap = <String, String>{};
      for (var doc in hostelsSnapshot.docs) {
        hostelMap[doc.id] = doc['name'] as String;
      }

      final roomTypeMap = <String, Map<String, dynamic>>{};
      for (var doc in roomTypesSnapshot.docs) {
        roomTypeMap[doc.id] = doc.data();
      }

      if (mounted) {
        setState(() {
          _hostelNames = hostelMap;
          _roomTypeData = roomTypeMap;
          _isLoadingMetadata = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading metadata: $e')));
        setState(() {
          _isLoadingMetadata = false;
        });
      }
    }
  }

  Future<void> _deleteRoom(String roomId) async {
    showDialog(
      context: context,
      builder: (context) => CustomModal(
        title: 'Delete Room',
        subtitle:
            'Are you sure you want to delete this room? This cannot be undone.',
        paramActionText: 'Delete',
        actionColor: Colors.red,
        isDestructive: true,
        onAction: () async {
          Navigator.pop(context); // Close modal first
          try {
            await FirebaseFirestore.instance
                .collection('rooms')
                .doc(roomId)
                .delete();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Room deleted successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error deleting room: $e')),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Rooms')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(
          '/admin/rooms/add',
          extra: widget.hostelId != null ? {'hostelId': widget.hostelId} : null,
        ),
        child: const Icon(Icons.add),
      ),
      body: _isLoadingMetadata
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search rooms by name/number...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.toLowerCase();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: widget.hostelId != null
                        ? FirebaseFirestore.instance
                              .collection('rooms')
                              .where('hostelId', isEqualTo: widget.hostelId)
                              .snapshots()
                        : FirebaseFirestore.instance
                              .collection('rooms')
                              .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final allRooms = snapshot.data!.docs;
                      final rooms = allRooms.where((room) {
                        final data = room.data() as Map<String, dynamic>;
                        final name =
                            (data['name'] as String?)?.toLowerCase() ?? '';
                        return name.contains(_searchQuery);
                      }).toList();

                      if (rooms.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.meeting_room_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No rooms found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: rooms.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final room = rooms[index];
                          final data = room.data() as Map<String, dynamic>;
                          final roomId = room.id;
                          final hostelId = data['hostelId'] as String?;
                          final roomTypeId = data['roomTypeId'] as String?;
                          final isAvailable =
                              data['isAvailable'] as bool? ?? false;

                          final hostelName =
                              _hostelNames[hostelId] ?? 'Unknown Hostel';

                          final roomTypeMap = _roomTypeData[roomTypeId];
                          final roomTypeName = roomTypeMap != null
                              ? (roomTypeMap['name'] as String)
                              : 'Unknown Type';
                          final capacity = roomTypeMap != null
                              ? (roomTypeMap['capacity'] as int)
                              : 0;
                          final occupantsList =
                              data['occupants'] as List<dynamic>? ?? [];
                          final currentOccupancy = occupantsList.length;

                          final isFull =
                              capacity > 0 && currentOccupancy >= capacity;
                          final statusColor = !isAvailable
                              ? Colors.red
                              : (isFull ? Colors.orange : Colors.green);
                          final statusLabel = !isAvailable
                              ? 'Unavailable'
                              : (isFull ? 'Full' : 'Available');

                          return Card(
                            elevation: 2,
                            shadowColor: Colors.black12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              onTap: () => context.push(
                                '/admin/rooms/edit/$roomId',
                                extra: data,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.bed,
                                        color: statusColor,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['name'] ?? 'Unnamed Room',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '$hostelName • $roomTypeName',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: statusColor
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  statusLabel,
                                                  style: TextStyle(
                                                    color: statusColor,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '$currentOccupancy/$capacity',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () => _deleteRoom(roomId),
                                    ),
                                  ],
                                ),
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
}
