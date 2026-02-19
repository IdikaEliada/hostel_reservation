import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hostel_reservation/widgets/app_footer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _navigateFromDrawer(
    BuildContext context,
    String path, {
    bool push = false,
  }) {
    Navigator.pop(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      push ? context.push(path) : context.go(path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      drawer: _buildDrawer(context),
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
          ],
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          _DrawerItem(
            icon: Icons.home,
            label: 'Home',
            onTap: () => _navigateFromDrawer(context, '/'),
          ),
          _DrawerItem(
            icon: Icons.feedback,
            label: 'Feedback',
            onTap: () => _navigateFromDrawer(context, '/feedback', push: true),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(leading: Icon(icon), title: Text(label), onTap: onTap);
  }
}
