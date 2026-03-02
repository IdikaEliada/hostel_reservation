# API Documentation

Complete API reference for SOE305 Notification Backend.

**Base URL**: `http://localhost:3000/api`

---

## Authentication

> [!WARNING]
> Current version has **NO authentication**. Add authentication middleware before deploying to production.

---

## Endpoints

### 1. Send Notification

Send a notification to a user via multiple channels (email, SMS, in-app).

**Endpoint**: `POST /api/notifications/send`

**Request Body**:
```json
{
  "userId": "string (required)",
  "event": "EventType (required)",
  "payload": "object (required)",
  "idempotencyKey": "string (optional)"
}
```

**Event Types**:
- `user_signup`
- `user_login`
- `password_reset`
- `password_changed`
- `booking_confirmation`
- `booking_cancelled`
- `payment_success`
- `payment_failed`
- `account_update`
- `security_alert`

**Example Request**:
```json
{
  "userId": "user_12345",
  "event": "booking_confirmation",
  "payload": {
    "userName": "John Doe",
    "bookingId": "BK-2024-001",
    "roomNumber": "205",
    "checkInDate": "2024-03-15",
    "checkOutDate": "2024-03-20"
  },
  "idempotencyKey": "booking_BK-2024-001"
}
```

**Success Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "userId": "user_12345",
    "event": "booking_confirmation",
    "status": "processing"
  },
  "message": "Notification sent successfully"
}
```

**Error Response** (400 Bad Request):
```json
{
  "success": false,
  "error": {
    "message": "Missing required fields: userId, event, and payload are required",
    "code": "VALIDATION_ERROR"
  }
}
```

---

### 2. Get User Notifications

Retrieve all notifications for a specific user.

**Endpoint**: `GET /api/notifications/:userId`

**URL Parameters**:
- `userId` (required) - The user ID

**Query Parameters**:
- `limit` (optional, default: 50) - Number of notifications to return
- `offset` (optional, default: 0) - Pagination offset

**Example Request**:
```
GET /api/notifications/user_12345?limit=20&offset=0
```

**Success Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "notifications": [
      {
        "id": "notif_abc123",
        "userId": "user_12345",
        "event": "booking_confirmation",
        "type": "transactional",
        "channel": "email",
        "title": "Booking Confirmed",
        "message": "Your booking has been confirmed...",
        "priority": "high",
        "status": "sent",
        "isRead": false,
        "idempotencyKey": "booking_BK-2024-001_email",
        "metadata": { /* payload data */ },
        "createdAt": "2024-01-15T10:30:00.000Z",
        "sentAt": "2024-01-15T10:30:05.000Z"
      }
    ],
    "count": 1
  }
}
```

---

### 3. Get Notification by ID

Retrieve a specific notification by its ID.

**Endpoint**: `GET /api/notifications/detail/:id`

**URL Parameters**:
- `id` (required) - The notification ID

**Example Request**:
```
GET /api/notifications/detail/notif_abc123
```

**Success Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "id": "notif_abc123",
    "userId": "user_12345",
    "event": "booking_confirmation",
    "type": "transactional",
    "channel": "email",
    "title": "Booking Confirmed",
    "message": "Your booking has been confirmed...",
    "priority": "high",
    "status": "sent",
    "isRead": false,
    "metadata": { /* payload data */ },
    "createdAt": "2024-01-15T10:30:00.000Z"
  }
}
```

**Error Response** (404 Not Found):
```json
{
  "success": false,
  "error": {
    "message": "Notification not found",
    "code": "NOT_FOUND"
  }
}
```

---

### 4. Mark Notification as Read

Mark a specific notification as read.

**Endpoint**: `PUT /api/notifications/:id/read`

**URL Parameters**:
- `id` (required) - The notification ID

**Example Request**:
```
PUT /api/notifications/notif_abc123/read
```

**Success Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "id": "notif_abc123",
    "isRead": true
  },
  "message": "Notification marked as read"
}
```

---

### 5. Health Check

Check if the server is running.

**Endpoint**: `GET /health`

**Success Response** (200 OK):
```json
{
  "success": true,
  "message": "SOE305 Notification Backend is running",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "environment": "development"
}
```

---

## Error Codes

| Code | Description |
|------|-------------|
| `VALIDATION_ERROR` | Missing or invalid request parameters |
| `INVALID_EVENT_TYPE` | Event type not supported |
| `SEND_ERROR` | Failed to send notification |
| `FETCH_ERROR` | Failed to fetch notifications |
| `UPDATE_ERROR` | Failed to update notification |
| `NOT_FOUND` | Resource not found |

---

## Response Structure

All API responses follow this structure:

**Success Response**:
```typescript
{
  success: true,
  data: any,
  message?: string
}
```

**Error Response**:
```typescript
{
  success: false,
  error: {
    message: string,
    code?: string,
    details?: any  // Only in development mode
  }
}
```

---

## Example Integration (Frontend)

### JavaScript/TypeScript

```typescript
// Send notification
async function sendNotification(userId: string, event: string, payload: object) {
  try {
    const response = await fetch('http://localhost:3000/api/notifications/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ userId, event, payload })
    });
    
    const result = await response.json();
    
    if (result.success) {
      console.log('Notification sent!', result.data);
    } else {
      console.error('Failed to send:', result.error.message);
    }
  } catch (error) {
    console.error('Network error:', error);
  }
}

// Get user notifications
async function getUserNotifications(userId: string) {
  try {
    const response = await fetch(`http://localhost:3000/api/notifications/${userId}`);
    const result = await response.json();
    
    if (result.success) {
      return result.data.notifications;
    } else {
      console.error('Failed to fetch:', result.error.message);
      return [];
    }
  } catch (error) {
    console.error('Network error:', error);
    return [];
  }
}

// Mark as read
async function markNotificationAsRead(notificationId: string) {
  try {
    const response = await fetch(
      `http://localhost:3000/api/notifications/${notificationId}/read`,
      { method: 'PUT' }
    );
    
    const result = await response.json();
    return result.success;
  } catch (error) {
    console.error('Network error:', error);
    return false;
  }
}
```

### Flutter/Dart

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationApi {
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Send notification
  static Future<bool> sendNotification({
    required String userId,
    required String event,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'event': event,
          'payload': payload,
        }),
      );
      
      final result = jsonDecode(response.body);
      return result['success'] == true;
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }
  
  // Get user notifications
  static Future<List<dynamic>> getUserNotifications(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/$userId'),
      );
      
      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        return result['data']['notifications'];
      }
      return [];
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }
}
```

---

## Testing with cURL

```bash
# Send notification
curl -X POST http://localhost:3000/api/notifications/send \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user123",
    "event": "user_signup",
    "payload": {
      "userName": "John Doe",
      "email": "john@example.com"
    }
  }'

# Get user notifications
curl http://localhost:3000/api/notifications/user123

# Get specific notification
curl http://localhost:3000/api/notifications/detail/notif_abc123

# Mark as read
curl -X PUT http://localhost:3000/api/notifications/notif_abc123/read

# Health check
curl http://localhost:3000/health
```

---

## Rate Limiting (Recommended for Production)

Consider adding rate limiting middleware:

```typescript
import rateLimit from 'express-rate-limit';

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});

app.use('/api/', limiter);
```

---

## CORS Configuration

Current setup allows all origins. For production, configure CORS properly:

```typescript
app.use(cors({
  origin: ['https://yourfrontend.com'],
  credentials: true
}));
```
