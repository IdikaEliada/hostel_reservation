# 🧪 Testing the Notification Backend

This guide will help you test the complete notification backend including **Email (SendGrid)** and **SMS (Termii)** functionality.

## 📋 Prerequisites

Your backend is already running at `http://localhost:3000` with:
- ✅ SendGrid API configured
- ✅ Termii API configured
- ✅ Firebase/Firestore connected

## 🚀 Quick Start - 3-Step Process

### Step 1: Setup Test User

First, update your email and phone number in the setup script:

1. Open `setup-test-user.ts`
2. Replace these values:
   ```typescript
   email: 'YOUR_EMAIL@example.com',     // Your real email
   phoneNumber: '+234XXXXXXXXXX',        // Your real phone number
   ```
3. Run the setup:
   ```bash
   npx tsx setup-test-user.ts
   ```

### Step 2: Run Automated Tests

Run the comprehensive test suite:

```bash
npx tsx test-notifications.ts
```

This will:
- ✅ Test the health endpoint
- 📧 Send test emails via SendGrid
- 📱 Send test SMS via Termii
- 💾 Verify notifications are stored in Firestore

### Step 3: Manual Verification

**Check your email inbox** 📧
- You should receive emails from: `obikachibuike15@gmail.com`
- Expected emails: Welcome email, Password reset, Booking confirmation

**Check your phone** 📱
- You should receive SMS from sender: `HostelApp`
- Expected messages: Same notifications as email

**Check server logs** 📝
- Watch your `npm run dev` terminal
- Look for: `✅ Email sent to...` and `✅ SMS sent to...`

## 🔍 Alternative Testing Methods

### Option A: Use the HTTP File (Manual Testing)

If you have VS Code REST Client extension:
1. Open `quick-test.http`
2. Update the `@userId` variable to match your test user
3. Click "Send Request" above any test

### Option B: Use cURL

```bash
# Health check
curl http://localhost:3000/health

# Send notification
curl -X POST http://localhost:3000/api/notifications/send \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "test-user-001",
    "event": "user_signup",
    "payload": {
      "userName": "Test User",
      "loginUrl": "https://yourapp.com/login"
    }
  }'

# Get user notifications
curl http://localhost:3000/api/notifications/test-user-001
```

## 📊 Available Event Types

You can test any of these event types:

| Event Type | Description | Priority |
|------------|-------------|----------|
| `user_signup` | Welcome email/SMS | High |
| `user_login` | Login notification | Low |
| `password_reset` | Password reset link | High |
| `password_changed` | Password change confirmation | High |
| `booking_confirmation` | Booking confirmed | High |
| `booking_cancelled` | Booking cancelled | High |
| `payment_success` | Payment successful | High |
| `payment_failed` | Payment failed | High |
| `account_update` | Account updated | Medium |
| `security_alert` | Security alert | High |

## 🐛 Troubleshooting

**No emails received?**
- Check SendGrid dashboard for delivery status
- Verify `SENDGRID_API_KEY` in `.env` is correct
- Check spam folder

**No SMS received?**
- Check Termii dashboard for delivery status
- Verify phone number format: `+234...` (country code required)
- Verify `TERMII_API_KEY` in `.env` is correct

**Notifications not in Firestore?**
- Check Firebase Console → Firestore Database
- Look for `notifications` collection
- Check `users` collection has your test user

## 📁 Test Files Created

- `setup-test-user.ts` - Creates test user in Firestore
- `test-notifications.ts` - Comprehensive automated test suite
- `quick-test.http` - HTTP requests for manual testing
- `TESTING.md` - This guide

## ✅ What Success Looks Like

After running the tests, you should see:

1. **In terminal**: `✅ All tests passed`
2. **In email**: Multiple test emails in your inbox
3. **On phone**: Multiple SMS messages received
4. **In Firestore**: New documents in `notifications` collection with status `sent`
5. **In server logs**: `✅ Email sent to...` and `✅ SMS sent to...` messages
