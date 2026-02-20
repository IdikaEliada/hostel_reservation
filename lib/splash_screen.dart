// presentation/screens/splash_screen.dart
//
// Purpose: Initial screen shown when the app launches.
// Responsibility: Displays university branding and performs background initialization/delay.
// Navigation: Success -> SignInScreen

import 'package:flutter/material.dart';

/// Animated entry screen with university logo and green theme.
// [LABEL: SPLASH SCREEN] - The first thing users see.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // No timer needed, router will redirect based on auth state when ready
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF008000), // FUTO Green
      body: Center(
        child: Container(
          width: 150,
          height: 150,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white, // In case image has transparency
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset('assets/images/futo_logo.png', fit: BoxFit.cover),
        ),
      ),
    );
  }
}
