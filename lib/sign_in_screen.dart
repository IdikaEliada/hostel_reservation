// presentation/screens/sign_in_screen.dart
//
// Purpose: Authentication entry point.
// Responsibility: Allows existing students to log in using their credentials.
//   Admin: hardcoded reg-number + password → unique key → admin dashboard.
// Navigation: Login -> MainScreen | "Sign Up" -> RegistrationScreen

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_theme.dart';
import 'notifications/fcm_token_store.dart';
import 'providers/auth_provider.dart';

// ── Admin hardcoded credentials ───────────────────────────────────────────────
const _kAdminRegNumber = 'ADMIN001';
const _kAdminPassword = 'Admin@2025!';
const _kAdminUniqueKey = 'HOSTEL-ADMIN-2025';
// ─────────────────────────────────────────────────────────────────────────────

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _keyFormKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureKey = true;
  bool _isLoading = false;
  bool _showAdminKeyStep = false; // true when step 2 (unique key) is visible

  final _regNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _uniqueKeyController = TextEditingController();

  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _regNumberController.dispose();
    _passwordController.dispose();
    _uniqueKeyController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  Sign In logic
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    final regNum = _regNumberController.text.trim();
    final password = _passwordController.text;

    // ── Admin check ──────────────────────────────────────────────────────────
    if (regNum == _kAdminRegNumber && password == _kAdminPassword) {
      setState(() => _showAdminKeyStep = true);
      _slideController.forward(from: 0);
      return;
    }

    // ── Normal user Firebase flow (unchanged) ────────────────────────────────
    setState(() => _isLoading = true);

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('regNumber', isEqualTo: regNum)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('No account found with this registration number.');
      }

      final email = querySnapshot.docs.first.get('email') as String;

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await saveFcmTokenForUser(user.uid);
        print("✅ Logged in uid: ${user.uid}");
      }

      // Auth state listener in router_provider handles redirect
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for this registration number.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        case 'invalid-email':
          message = 'Invalid email format.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        default:
          message = 'Sign in failed: ${e.message}';
      }
      _showError(message);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Verify the unique admin key ────────────────────────────────────────────
  void _verifyAdminKey() {
    if (!_keyFormKey.currentState!.validate()) return;

    if (_uniqueKeyController.text.trim() == _kAdminUniqueKey) {
      // Mark admin as authenticated in Riverpod so the router allows /admin/*
      ref.read(adminAuthProvider.notifier).setAuthenticated();
      context.go('/admin/hostels');
    } else {
      _showError('Invalid admin key. Access denied.');
    }
  }

  // ── Go back to step 1 ─────────────────────────────────────────────────────
  void _backToCredentials() {
    _slideController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showAdminKeyStep = false;
          _uniqueKeyController.clear();
        });
      }
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  Build
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Logo ─────────────────────────────────────────────────
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/futo_logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hostel Reservation',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _showAdminKeyStep
                          ? 'Enter your admin unique key to continue'
                          : 'Sign in to manage your accommodation',
                      key: ValueKey(_showAdminKeyStep),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Step 1: Credentials form ──────────────────────────────
                  AnimatedOpacity(
                    opacity: _showAdminKeyStep ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    child: IgnorePointer(
                      ignoring: _showAdminKeyStep,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _fieldLabel('Reg Number', isDark),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _regNumberController,
                              decoration: const InputDecoration(
                                hintText: 'e.g., 2018/123456',
                              ),
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            _fieldLabel('Password', isDark),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: 'Enter your password',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey.shade400,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                              ),
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: const Text('Forgot Password?'),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _signIn,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Sign In'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Step 2: Admin unique key ──────────────────────────────
                  if (_showAdminKeyStep)
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _slideController,
                        child: Form(
                          key: _keyFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Admin badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(
                                    0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.primaryColor.withOpacity(
                                      0.3,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.admin_panel_settings_rounded,
                                      color: AppTheme.primaryColor,
                                      size: 20,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Admin Access Detected',
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              _fieldLabel('Unique Key', isDark),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _uniqueKeyController,
                                obscureText: _obscureKey,
                                decoration: InputDecoration(
                                  hintText: 'Enter your unique admin key',
                                  prefixIcon: const Icon(
                                    Icons.key_rounded,
                                    color: AppTheme.primaryColor,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureKey
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.grey.shade400,
                                    ),
                                    onPressed: () => setState(
                                      () => _obscureKey = !_obscureKey,
                                    ),
                                  ),
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Required'
                                    : null,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _verifyAdminKey,
                                child: const Text('Access Admin Dashboard'),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: _backToCredentials,
                                child: const Text(
                                  '← Back to Sign In',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // ── Footer: Sign Up link (hidden during key step) ─────────
                  if (!_showAdminKeyStep) ...[
                    const SizedBox(height: 48),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 32),
                  Container(
                    width: 100,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text, bool isDark) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.grey.shade200 : const Color(0xFF0F172A),
      ),
    );
  }
}
