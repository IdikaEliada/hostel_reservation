import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class FirestoreNotificationService {
final FirebaseFirestore _db = FirebaseFirestore.instance;

// Stream notifications for a specific user
Stream<List<NotificationModel>> getUserNotifications(String userId) {
return _db
.collection('notifications')
.where('userId', isEqualTo: userId)
// ✅ channel is List<String> now, so use arrayContains
.where('channel', arrayContains: 'in_app')
.orderBy('createdAt', descending: true)
.snapshots()
.map((snapshot) => snapshot.docs
.map((doc) => NotificationModel.fromFirestore(doc))
.toList());
}

// Mark notification as read
Future<void> markAsRead(String notificationId) async {
try {
await _db.collection('notifications').doc(notificationId).update({'isRead': true});
} catch (e) {
print('Error marking notification as read: $e');
}
}

// Get unread count stream
Stream<int> getUnreadCount(String userId) {
return _db
.collection('notifications')
.where('userId', isEqualTo: userId)
.where('channel', arrayContains: 'in_app')
.where('isRead', isEqualTo: false)
.snapshots()
.map((snapshot) => snapshot.docs.length);
}
}
