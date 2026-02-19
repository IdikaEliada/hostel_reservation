import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        children: [
          // IconButton(
          //   icon: const Icon(Icons.home),
          //   onPressed: () => context.go('/home'),
          //   tooltip: 'Home',
          // ),
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
