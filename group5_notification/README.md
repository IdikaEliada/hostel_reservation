 HEAD
# soe305-project-
# Hostel Notification Backend & App 

A complete notification system for the Hostel Management Platform.

## Flutter UI App (`notification_app/`)
This repo includes a production-ready Flutter app for displaying notifications.
- **Features**: Real-time updates, Mark as Read, Event-specific icons (Booking, Payment, Security).
- **Location**: `./notification_app`

 **[Read the Integration Guide](INTEGRATION_GUIDE.md)** for full details.

##  Backend Setup

Production-ready notification system supporting **Email**, **SMS**, and **In-App** notifications for the SOE305 project.

##  Features

- ✅ Multi-channel notifications (Email via SendGrid, SMS via Termii, In-App)
- ✅ Event-driven architecture with predefined event types
- ✅ Template system for consistent messaging
- ✅ Firebase Firestore integration for persistence
- ✅ RESTful API for frontend integration
- ✅ TypeScript for type safety
- ✅ Idempotency support to prevent duplicate notifications

##  Prerequisites

- Node.js (v16 or higher)
- npm or yarn
- Firebase project with Firestore enabled
- SendGrid account and API key
- Termii account and API key

##  Setup Instructions

### 1. Clone and Install Dependencies

```bash
cd "c:\Users\prosper\OneDrive\Desktop\soe305 notification backend"
npm install
```

### 2. Configure Environment Variables

Create a `.env` file in the root directory (use `.env.example` as template):

```bash
# Server Configuration
PORT=3000

# Firebase Configuration
FIREBASE_DATABASE_URL=https://hostelreservation-1defd.firebaseio.com

# SendGrid Configuration
SENDGRID_API_KEY=your_sendgrid_api_key
FROM_EMAIL=noreply@yourdomain.com

# Termii Configuration
TERMII_API_KEY=your_termii_api_key
TERMII_SENDER_ID=YourApp

# Application URL
APP_URL=https://yourapp.com
```

### 3. Add Firebase Service Account Key

Place your `serviceAccountKey.json` file in the project root directory. Get this from:
- Firebase Console → Project Settings → Service Accounts → Generate New Private Key

**Never commit this file to version control!**

### 4. Run the Server

**Development mode** (with auto-reload):
```bash
npm run dev
```

**Production mode**:
```bash
npm run build
npm start
```

The server will start on `http://localhost:3000`

##  Contributors
Proudly built by **Chinyeaka Prosper Uzoma** and team.
 **[View Full Team List](CONTRIBUTORS.md)**.

## 📡 API Endpoints

See [API_DOCS.md](./API_DOCS.md) for detailed API documentation.

**Quick Reference:**
- `POST /api/notifications/send` - Send a notification
- `GET /api/notifications/:userId` - Get user notifications
- `GET /api/notifications/detail/:id` - Get specific notification
- `PUT /api/notifications/:id/read` - Mark notification as read
- `GET /health` - Health check

##  Supported Event Types

- `user_signup` - New user registration
- `user_login` - User login notification
- `password_reset` - Password reset request
- `password_changed` - Password successfully changed
- `booking_confirmation` - Booking confirmed
- `booking_cancelled` - Booking cancelled
- `payment_success` - Payment processed successfully
- `payment_failed` - Payment processing failed
- `account_update` - Account information updated
- `security_alert` - Security-related alert

##  Testing

```bash
npm test
```

## Project Structure

```
src/
├── config/           # Configuration files
│   └── firebase.ts   # Firebase Admin SDK setup
├── controllers/      # Request handlers
│   └── NotificationController.ts
├── middleware/       # Express middleware
│   └── errorHandler.ts
├── models/           # TypeScript interfaces & types
│   ├── Events.ts
│   └── Notification.ts
├── repositories/     # Data access layer
│   └── NotificationRepository.ts
├── routes/           # API routes
│   └── notification.routes.ts
├── services/         # Business logic
│   ├── NotificationService.ts
│   └── ChannelServices.ts
├── templates/        # Notification templates
│   ├── TemplateManager.ts
│   └── index.ts
└── index.ts          # Application entry point
```

##  Deployment

### Build for Production

```bash
npm run build
```

This creates a `dist/` folder with compiled JavaScript.

### Environment Variables in Production

Ensure all environment variables are set in your deployment platform:
- Heroku: Use `heroku config:set`
- Railway: Set in project settings
- Google Cloud Run: Use Secret Manager
- AWS: Use Parameter Store or Secrets Manager

### Firebase Service Account

Upload `serviceAccountKey.json` securely:
- Use environment secrets (recommended)
- Or use `GOOGLE_APPLICATION_CREDENTIALS` environment variable

##  Security Notes

- ✅ `.env` and `serviceAccountKey.json` are in `.gitignore`
- ⚠️ Add authentication middleware in production
- ⚠️ Rate limiting recommended for public endpoints
- ⚠️ Validate all user inputs

##  Frontend Integration

Frontend teams can integrate by making HTTP requests to the API endpoints.

Example (JavaScript/TypeScript):
```typescript
const response = await fetch('http://localhost:3000/api/notifications/send', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    userId: 'user123',
    event: 'booking_confirmation',
    payload: {
      bookingId: 'BK123',
      roomNumber: '205',
      checkInDate: '2024-03-15'
    }
  })
});

const result = await response.json();
```

See [API_DOCS.md](./API_DOCS.md) for complete examples.

For issues or questions, contact the backend team.

MIT
 b84fe15 (Initial notification backend implementation)
