import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:hostel_reservation/widgets/app_footer.dart';

class HostelListScreen extends StatelessWidget {
  const HostelListScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      bottomNavigationBar: const AppFooter(),
      appBar: AppBar(title: const Text('Hostels')),
      bottomNavigationBar: const AppFooter(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('hostels').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
          final String userGender = (userData?['gender'] ?? '')
              .toString()
              .toLowerCase();
          // Assuming gender is stored as 'male', 'female', etc.

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('hostels')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final hostels = snapshot.data!.docs;

              if (hostels.isEmpty) {
                return const Center(child: Text('No hostels found.'));
              }

              // Sort hostels by name to ensure A-F order if needed
              hostels.sort((a, b) {
                final nameA = (a.data() as Map<String, dynamic>)['name'] ?? '';
                final nameB = (b.data() as Map<String, dynamic>)['name'] ?? '';
                return nameA.compareTo(nameB);
              });

              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: hostels.length,
                itemBuilder: (context, index) {
                  final hostel = hostels[index];
                  final data = hostel.data() as Map<String, dynamic>;
                  final String hostelName = (data['name'] ?? '').toString();
                  // Normalize name for checking
                  final String nameLower = hostelName.toLowerCase();

                  // Determine hostel gender
                  // A, B, E -> Male
                  // C, D, F -> Female (implied "others")
                  bool isMaleHostel = false;
                  if (nameLower.contains('hostel a') ||
                      nameLower.contains('hostel b') ||
                      nameLower.contains('hostel e')) {
                    isMaleHostel = true;
                  }

                  // Determine if we should blur
                  // Blur if user is male and hostel is NOT male (i.e. female)
                  // Blur if user is female and hostel IS male
                  bool shouldBlur = false;
                  if (userGender == 'male' && !isMaleHostel) {
                    shouldBlur = true;
                  } else if (userGender == 'female' && isMaleHostel) {
                    shouldBlur = true;
                  }

                  // Assign assets based on hostel name (mock logic as requested)
                  // hostel1 in assets for hostel a, etc.
                  String assetImage = 'assets/images/hostel1.jpeg'; // Default

                  if (nameLower.contains('hostel a')) {
                    assetImage = 'assets/images/hostel1.jpeg';
                  } else if (nameLower.contains('hostel b')) {
                    assetImage = 'assets/images/hostel2.jpeg';
                  } else if (nameLower.contains('hostel c')) {
                    assetImage = 'assets/images/hostel3.jpeg';
                  } else if (nameLower.contains('hostel d')) {
                    assetImage = 'assets/images/hostel4.jpeg';
                  } else if (nameLower.contains('hostel e')) {
                    assetImage = 'assets/images/hostel5.jpeg';
                  } else if (nameLower.contains('hostel f')) {
                    assetImage = 'assets/images/hostel6.jpeg';
                  }

                  return InkWell(
                    onTap: shouldBlur
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('You cannot view this hostel.'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        : () {
                            context.go('/hostel/${hostel.id}', extra: data);
                          },
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background Image
                          Image.asset(
                            assetImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to network or generic if asset missing
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.home, size: 50),
                              );
                            },
                          ),

                          // Gradient Overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),

                          // Blur Effect Overlay
                          if (shouldBlur)
                            BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 10.0,
                                sigmaY: 10.0,
                              ),
                              child: Container(
                                color: Colors.black.withOpacity(0.2),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.lock,
                                  color: Colors.white70,
                                  size: 48,
                                ),
                              ),
                            ),

                          // Content
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hostelName,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.bed,
                                      size: 14,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '${data['availableRooms']} / ${data['totalRooms']}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.white70),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
    );
  }
}
