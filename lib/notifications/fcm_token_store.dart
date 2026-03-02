import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> saveFcmTokenForUser(String userId) async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token == null) {
    print('❌ No FCM token yet');
    return;
  }

  await FirebaseFirestore.instance.collection('user_tokens').doc(userId).set({
    'token': token,
    'updatedAt': FieldValue.serverTimestamp(),
    'platform': 'android',
  }, SetOptions(merge: true));

  print('✅ Saved FCM token for $userId: $token');
}
