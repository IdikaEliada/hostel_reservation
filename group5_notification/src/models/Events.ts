import { NotificationType } from './Notification';

export type EventType =
    | 'user_signup'
    | 'user_login'
    | 'password_reset'
    | 'password_changed'
    | 'booking_confirmation'
    | 'booking_cancelled'
    | 'payment_success'
    | 'payment_failed'
    | 'account_update'
    | 'security_alert';

export interface EventConfig {
    type: NotificationType;
    priority: 'high' | 'medium' | 'low';
    description: string;
}

export const EVENT_CONFIGS: Record<EventType, EventConfig> = {
    user_signup: {
        type: 'transactional',
        priority: 'high',
        description: 'New user registration confirmation'
    },
    user_login: {
        type: 'system',
        priority: 'low',
        description: 'User login notification'
    },
    password_reset: {
        type: 'transactional',
        priority: 'high',
        description: 'Password reset request'
    },
    password_changed: {
        type: 'transactional',
        priority: 'high',
        description: 'Password successfully changed'
    },
    booking_confirmation: {
        type: 'transactional',
        priority: 'high',
        description: 'Booking confirmed'
    },
    booking_cancelled: {
        type: 'transactional',
        priority: 'high',
        description: 'Booking cancelled'
    },
    payment_success: {
        type: 'transactional',
        priority: 'high',
        description: 'Payment processed successfully'
    },
    payment_failed: {
        type: 'transactional',
        priority: 'high',
        description: 'Payment processing failed'
    },
    account_update: {
        type: 'system',
        priority: 'medium',
        description: 'Account information updated'
    },
    security_alert: {
        type: 'system',
        priority: 'high',
        description: 'Security-related alert'
    }
};
