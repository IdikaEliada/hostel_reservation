import { EventType } from './Events';

export type NotificationChannel = 'email' | 'sms' | 'in_app' | 'push';

export type NotificationStatus = 'pending' | 'sent' | 'failed';

export type NotificationType = 'transactional' | 'promotional' | 'system';

export interface NotificationRecord {
    id: string;
    userId: string;
    event: EventType;
    type: NotificationType;
    channel: NotificationChannel;
    title: string;
    message: string;
    priority: 'high' | 'medium' | 'low';
    status: NotificationStatus;
    isRead: boolean;
    idempotencyKey: string;
    metadata?: Record<string, any>;
    errorMessage?: string;
    createdAt: Date;
    sentAt?: Date;
    readAt?: Date;
}

export interface SendNotificationRequest {
    userId: string;
    event: EventType;
    payload: Record<string, any>;
    idempotencyKey?: string;
}
