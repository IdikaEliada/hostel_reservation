import 'dart:math';
import 'backend_notification_service.dart';

class NotificationDispatcherBackend {
  /// Map your old "type" to backend "event"
  String _mapTypeToEvent(String type) {
    switch (type) {
      case 'BOOKING_CONFIRMED':
        return 'booking_confirmation';
      case 'PAYMENT_SUCCESS':
        return 'payment_success';
      case 'PASSWORD_CREATED':
        return 'user_signup';
      default:
        return 'account_update';
    }
  }

  Future<bool> dispatch({
    required String userId,
    required String type,
    required Map<String, dynamic> metadata,
    List<String> channel = const ['in_app'], // or ['email'], ['sms'], ['email','sms']
  }) async {
    final event = _mapTypeToEvent(type);

    // backend expects payload
    final payload = {
      ...metadata,
      'type': type,
      'channel': channel.join(','), // keep same idea you used before
    };

    final idempotencyKey = '${userId}_${type}_${Random().nextInt(999999)}';

    return BackendNotificationService.send(
      userId: userId,
      event: event,
      payload: payload,
      idempotencyKey: idempotencyKey,
    );
  }
}
