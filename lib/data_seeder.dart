import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> seedHostelData() async {
  final firestore = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser;

  try {
    print('Seeding database...');

    // 1. Ensure Room Types Exist (Reuse if available to avoid duplicates)
    final List<Map<String, dynamic>> roomTypesData = [
      {'name': 'Single Room', 'capacity': 1, 'price': 1000},
      {'name': 'Double Room', 'capacity': 2, 'price': 1500},
      {'name': 'Dormitory Bed', 'capacity': 1, 'price': 500},
    ];

    print('Checking/Creating room types...');
    List<String> roomTypeIds = [];

    for (var typeData in roomTypesData) {
      final String typeName = typeData['name'];
      final existingTypeQuery = await firestore
          .collection('room_types')
          .where('name', isEqualTo: typeName)
          .limit(1)
          .get();

      if (existingTypeQuery.docs.isNotEmpty) {
        // print('Using existing room type: $typeName');
        roomTypeIds.add(existingTypeQuery.docs.first.id);
      } else {
        print('Creating new room type: $typeName');
        final typeRef = await firestore.collection('room_types').add({
          ...typeData,
          'createdAt': FieldValue.serverTimestamp(),
        });
        roomTypeIds.add(typeRef.id);
      }
    }

    /*
    // 2. Seed Hostels (A to F)
    final List<String> hostelNames = [
      'Hostel A',
      'Hostel B',
      'Hostel C',
      'Hostel D',
      'Hostel E',
      'Hostel F',
    ];

    final List<String> imageUrls = [
      'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1611892440504-42a792e24d32?auto=format&fit=crop&w=600&q=80',
    ];

    for (final name in hostelNames) {
      print('Creating $name...');

      final hostelRef = await firestore.collection('hostels').add({
        'name': name,
        'totalRooms': 20,
        'availableRooms': 20,
        'imageUrls': imageUrls,
        'imageUrl': imageUrls[0],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create Rooms for this Hostel
      final WriteBatch batch = firestore.batch();
      for (int i = 1; i <= 20; i++) {
        final roomRef = firestore.collection('rooms').doc();
        // Cycle room types
        final roomTypeId = roomTypeIds[(i - 1) % roomTypeIds.length];

        batch.set(roomRef, {
          'hostelId': hostelRef.id,
          'name': 'Room $i',
          'roomTypeId': roomTypeId,
          'isAvailable': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    }
    */

    // 2. Add 5 rooms to ALL existing hostels
    print('Fetching existing hostels...');
    final hostelQuery = await firestore.collection('hostels').get();

    if (hostelQuery.docs.isEmpty) {
      print(
        'No hostels found. Please uncomment the hostel creation logic first.',
      );
    } else {
      for (final hostelDoc in hostelQuery.docs) {
        final hostelId = hostelDoc.id;
        final hostelName = hostelDoc.data()['name'] ?? 'Unknown Hostel';
        print('Adding 5 rooms to $hostelName ($hostelId)...');

        final WriteBatch batch = firestore.batch();
        // Create 5 rooms
        for (int i = 1; i <= 5; i++) {
          final roomRef = firestore.collection('rooms').doc();
          // Cycle room types
          final roomTypeId = roomTypeIds[(i - 1) % roomTypeIds.length];
          // Determine name - using a suffix to maybe distinguish
          final roomName = 'Extra Room $i';

          batch.set(roomRef, {
            'hostelId': hostelId,
            'name': roomName,
            'roomTypeId': roomTypeId,
            'isAvailable': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
        print('Added 5 rooms to $hostelName');
      }
    }

    // 3. Seed current user document (once)
    if (currentUser != null) {
      await firestore.collection('users').doc(currentUser.uid).set({
        'name': 'Test User',
        'email': currentUser.email ?? 'test@email.com',
        'phone': '08012345678',
        'location': 'Lagos, Nigeria',
        'avatarUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('User document updated: ${currentUser.uid}');
    }

    print('Seeding completed successfully!');
  } catch (e) {
    print('Error seeding data: $e');
  }
}
