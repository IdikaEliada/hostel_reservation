import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final List<String> channel; // Changed to List based on new contract
  final bool isRead;
  final String status; // 'pending', 'sent', 'failed'
  final DateTime createdAt;
  final String type; // 'PAYMENT_SUCCESS', etc.
  final Map<String, dynamic> metadata;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.channel,
    required this.isRead,
    required this.status,
    required this.createdAt,
    required this.type,
    required this.metadata,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Handle channel being either string or list for backward compatibility
    List<String> parsedChannels = [];
    if (data['channel'] is String) {
      parsedChannels = [data['channel']];
    } else if (data['channel'] is List) {
      parsedChannels = List<String>.from(data['channel']);
    }

    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      channel: parsedChannels,
      isRead: data['isRead'] ?? false,
      status: data['status'] ?? 'unknown',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: data['type'] ?? 'info',
      metadata: data['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'channel': channel,
      'isRead': isRead,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'type': type,
      'metadata': metadata,
    };
  }
}
