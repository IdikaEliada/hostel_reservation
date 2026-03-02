import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Stream provider that listens to auth state changes
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Tracks whether the hardcoded admin has been authenticated via unique key.
// In-memory only — resets when the app is restarted (intentional).
class AdminAuthNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setAuthenticated() => state = true;
  void clearAuthenticated() => state = false;
}

final adminAuthProvider = NotifierProvider<AdminAuthNotifier, bool>(
  AdminAuthNotifier.new,
);
