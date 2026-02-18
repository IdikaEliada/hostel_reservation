import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/hostels'),
              child: const Text('View Hostels'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/admin/rooms'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
              ),
              child: const Text('Admin Dashboard'),
            ),
            //Added a button to view profile
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go('/profile'),
              child: const Text('Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
