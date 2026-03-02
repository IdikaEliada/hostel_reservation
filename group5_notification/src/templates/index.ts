// index.ts
import { TemplateSet } from './TemplateManager';

export const templates: Record<string, TemplateSet> = {
  user_signup: {
    email: {
      subject: 'Welcome to Our Platform! 🎉',
      body: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #4F46E5;">Welcome, {{username}}!</h2>
          <p>Thank you for joining our platform. We're excited to have you on board.</p>
          <p>Your account has been successfully created with the email: <strong>{{email}}</strong></p>
          <p>Get started by exploring our features and setting up your profile.</p>
          <div style="margin: 30px 0;">
            <a href="{{appUrl}}" style="background-color: #4F46E5; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px;">
              Get Started
            </a>
          </div>
          <p style="color: #666; font-size: 14px;">If you have any questions, feel free to reach out to our support team.</p>
        </div>
      `,
    },
    sms: {
      body:
        'Welcome to our platform, {{username}}! Your account has been created successfully. Start exploring now!',
    },
    in_app: {
      body: 'Welcome aboard! Your account is ready to use.',
    },
    push: {
      subject: 'Welcome 🎉',
      body: 'Your account is ready. Tap to get started.',
    },
  },

  password_reset: {
    email: {
      subject: 'Password Reset Request 🔐',
      body: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #DC2626;">Password Reset Request</h2>
          <p>Hi {{username}},</p>
          <p>We received a request to reset your password. Click the button below to create a new password:</p>
          <div style="margin: 30px 0;">
            <a href="{{resetLink}}" style="background-color: #DC2626; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px;">
              Reset Password
            </a>
          </div>
          <p>This link will expire in {{expiryMinutes}} minutes.</p>
          <p style="color: #666; font-size: 14px;">If you didn't request this, please ignore this email or contact support if you have concerns.</p>
          <p style="color: #666; font-size: 12px; margin-top: 30px;">Security tip: Never share this link with anyone.</p>
        </div>
      `,
    },
    sms: {
      body:
        'Password reset requested for your account. Use this code: {{resetCode}}. Expires in {{expiryMinutes}} minutes.',
    },
    in_app: {
      body: 'Password reset link sent to your email.',
    },
    push: {
      subject: 'Password Reset 🔐',
      body: 'A password reset was requested for your account.',
    },
  },

  password_changed: {
    email: {
      subject: 'Password Changed Successfully ✓',
      body: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #10B981;">Password Changed Successfully</h2>
          <p>Hi {{username}},</p>
          <p>Your password was changed successfully on {{timestamp}}.</p>
          <p style="color: #666;">If you didn't make this change, please contact our support team immediately.</p>
          <div style="margin: 30px 0; padding: 15px; background-color: #FEF3C7; border-left: 4px solid #F59E0B;">
            <strong>Security Alert:</strong> If this wasn't you, secure your account now.
          </div>
        </div>
      `,
    },
    sms: {
      body: "Your password was changed successfully. If this wasn't you, contact support immediately.",
    },
    in_app: {
      body: 'Your password has been changed successfully.',
    },
    push: {
      subject: 'Password Changed ✓',
      body: 'Your password was changed. If this wasn’t you, secure your account.',
    },
  },

  booking_confirmation: {
    email: {
      subject: 'Booking Confirmed! 📅',
      body: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #10B981;">Booking Confirmed!</h2>
          <p>Hi {{username}},</p>
          <p>Your booking has been confirmed. Here are the details:</p>
          <div style="background-color: #F3F4F6; padding: 20px; border-radius: 8px; margin: 20px 0;">
            <p><strong>Booking ID:</strong> {{bookingId}}</p>
            <p><strong>Date:</strong> {{bookingDate}}</p>
            <p><strong>Time:</strong> {{bookingTime}}</p>
            <p><strong>Location:</strong> {{location}}</p>
          </div>
          <p>We look forward to seeing you!</p>
          <div style="margin: 30px 0;">
            <a href="{{bookingDetailsUrl}}" style="background-color: #10B981; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px;">
              View Booking Details
            </a>
          </div>
        </div>
      `,
    },
    sms: {
      body:
        'Booking confirmed! ID: {{bookingId}}. Date: {{bookingDate}} at {{bookingTime}}. Location: {{location}}',
    },
    in_app: {
      body: 'Your booking #{{bookingId}} has been confirmed for {{bookingDate}}.',
    },
    push: {
      subject: 'Booking Confirmed 📅',
      body: 'Booking #{{bookingId}} confirmed for {{bookingDate}}.',
    },
  },

  booking_cancelled: {
    email: {
      subject: 'Booking Cancelled',
      body: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #DC2626;">Booking Cancelled</h2>
          <p>Hi {{username}},</p>
          <p>Your booking #{{bookingId}} has been cancelled as requested.</p>
          <p>If you have any questions or wish to make a new booking, please contact us.</p>
        </div>
      `,
    },
    sms: {
      body: 'Booking #{{bookingId}} has been cancelled. Contact us if you need assistance.',
    },
    in_app: {
      body: 'Booking #{{bookingId}} cancelled successfully.',
    },
    push: {
      subject: 'Booking Cancelled',
      body: 'Booking #{{bookingId}} was cancelled.',
    },
  },

  payment_success: {
    email: {
      subject: 'Payment Successful! 💳',
      body: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #10B981;">Payment Successful!</h2>
          <p>Hi {{username}},</p>
          <p>Your payment has been processed successfully.</p>
          <div style="background-color: #F3F4F6; padding: 20px; border-radius: 8px; margin: 20px 0;">
            <p><strong>Transaction ID:</strong> {{transactionId}}</p>
            <p><strong>Amount:</strong> {{amount}} {{currency}}</p>
            <p><strong>Date:</strong> {{timestamp}}</p>
          </div>
          <p>Thank you for your payment!</p>
        </div>
      `,
    },
    sms: {
      body: 'Payment successful! Amount: {{amount}} {{currency}}. Transaction ID: {{transactionId}}',
    },
    in_app: {
      body: 'Payment of {{amount}} {{currency}} processed successfully.',
    },
    push: {
      subject: 'Payment Successful 💳',
      body: '{{amount}} {{currency}} received. Tx: {{transactionId}}',
    },
  },

  payment_failed: {
    email: {
      subject: 'Payment Failed ⚠️',
      body: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #DC2626;">Payment Failed</h2>
          <p>Hi {{username}},</p>
          <p>Unfortunately, your payment could not be processed.</p>
          <p><strong>Reason:</strong> {{failureReason}}</p>
          <p>Please try again or use a different payment method.</p>
          <div style="margin: 30px 0;">
            <a href="{{retryPaymentUrl}}" style="background-color: #DC2626; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px;">
              Retry Payment
            </a>
          </div>
        </div>
      `,
    },
    sms: {
      body: 'Payment failed. Reason: {{failureReason}}. Please try again.',
    },
    in_app: {
      body: 'Payment failed: {{failureReason}}. Please try again.',
    },
    push: {
      subject: 'Payment Failed ⚠️',
      body: '{{failureReason}}',
    },
  },

  security_alert: {
    email: {
      subject: '🔒 Security Alert - Account Activity',
      body: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #DC2626;">Security Alert</h2>
          <p>Hi {{username}},</p>
          <p>We detected unusual activity on your account:</p>
          <div style="background-color: #FEE2E2; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #DC2626;">
            <p><strong>Activity:</strong> {{activityType}}</p>
            <p><strong>Time:</strong> {{timestamp}}</p>
            <p><strong>Location:</strong> {{location}}</p>
          </div>
          <p>If this was you, you can safely ignore this message. Otherwise, please secure your account immediately.</p>
          <div style="margin: 30px 0;">
            <a href="{{secureAccountUrl}}" style="background-color: #DC2626; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px;">
              Secure My Account
            </a>
          </div>
        </div>
      `,
    },
    sms: {
      body:
        "Security Alert: {{activityType}} detected on your account. If this wasn't you, secure your account now.",
    },
    in_app: {
      body: 'Security alert: {{activityType}} detected. Review your account activity.',
    },
    push: {
      subject: 'Security Alert 🔒',
      body: '{{activityType}} detected. Check your account.',
    },
  },
};
