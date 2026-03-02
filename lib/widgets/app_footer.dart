import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      height: 60, // Reduces overall height
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.bed),
            onPressed: () => context.go('/hostels'),
            tooltip: 'Hostels',
          ),
          Spacer(),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/profile'),
            tooltip: 'Profile',
          ),
        ],
      ),
    );
  }
}
