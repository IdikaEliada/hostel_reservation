import { Request, Response } from 'express';
import { NotificationService } from '../services/NotificationService';
import { NotificationRepository } from '../repositories/NotificationRepository';
import { EventType } from '../models/Events';

interface SuccessResponse<T = any> {
    success: true;
    data: T;
    message?: string;
}

interface ErrorResponse {
    success: false;
    error: {
        message: string;
        code?: string;
    };
}

export const NotificationController = {
    /**
     * POST /api/notifications/send
     * Send a notification to a user
     */
    async sendNotification(req: Request, res: Response): Promise<void> {
        try {
            const { userId, event, payload, idempotencyKey } = req.body;

            // Validation
            if (!userId || !event || !payload) {
                res.status(400).json({
                    success: false,
                    error: {
                        message: 'Missing required fields: userId, event, and payload are required',
                        code: 'VALIDATION_ERROR'
                    }
                } as ErrorResponse);
                return;
            }

            // Validate event type
            const validEvents: EventType[] = [
                'user_signup',
                'user_login',
                'password_reset',
                'password_changed',
                'booking_confirmation',
                'booking_cancelled',
                'payment_success',
                'payment_failed',
                'account_update',
                'security_alert'
            ];

            if (!validEvents.includes(event as EventType)) {
                res.status(400).json({
                    success: false,
                    error: {
                        message: `Invalid event type. Must be one of: ${validEvents.join(', ')}`,
                        code: 'INVALID_EVENT_TYPE'
                    }
                } as ErrorResponse);
                return;
            }

            // Send notification
            await NotificationService.sendNotification({
                userId,
                event: event as EventType,
                payload,
                idempotencyKey
            });

            const response: SuccessResponse = {
                success: true,
                data: {
                    userId,
                    event,
                    status: 'processing'
                },
                message: 'Notification sent successfully'
            };

            res.status(200).json(response);
        } catch (error: any) {
            console.error('Error in sendNotification:', error);
            res.status(500).json({
                success: false,
                error: {
                    message: error.message || 'Failed to send notification',
                    code: 'SEND_ERROR'
                }
            } as ErrorResponse);
        }
    },

    /**
     * GET /api/notifications/:userId
     * Get all notifications for a specific user
     */
    async getUserNotifications(req: Request, res: Response): Promise<void> {
        try {
            const { userId } = req.params;
            const { limit, offset } = req.query;

            if (!userId) {
                res.status(400).json({
                    success: false,
                    error: {
                        message: 'userId parameter is required',
                        code: 'VALIDATION_ERROR'
                    }
                } as ErrorResponse);
                return;
            }

            const notifications = await NotificationRepository.findByUserId(
                userId,
                limit ? parseInt(limit as string) : 50,
                offset ? parseInt(offset as string) : 0
            );

            const response: SuccessResponse = {
                success: true,
                data: {
                    notifications,
                    count: notifications.length
                }
            };

            res.status(200).json(response);
        } catch (error: any) {
            console.error('Error in getUserNotifications:', error);
            res.status(500).json({
                success: false,
                error: {
                    message: error.message || 'Failed to fetch notifications',
                    code: 'FETCH_ERROR'
                }
            } as ErrorResponse);
        }
    },

    /**
     * GET /api/notifications/detail/:id
     */
    async getNotificationById(req: Request, res: Response): Promise<void> {
        try {
            const { id } = req.params;

            if (!id) {
                res.status(400).json({
                    success: false,
                    error: {
                        message: 'Notification ID is required',
                        code: 'VALIDATION_ERROR'
                    }
                } as ErrorResponse);
                return;
            }

            const notification = await NotificationRepository.findById(id);

            if (!notification) {
                res.status(404).json({
                    success: false,
                    error: {
                        message: 'Notification not found',
                        code: 'NOT_FOUND'
                    }
                } as ErrorResponse);
                return;
            }

            const response: SuccessResponse = {
                success: true,
                data: notification
            };

            res.status(200).json(response);
        } catch (error: any) {
            console.error('Error in getNotificationById:', error);
            res.status(500).json({
                success: false,
                error: {
                    message: error.message || 'Failed to fetch notification',
                    code: 'FETCH_ERROR'
                }
            } as ErrorResponse);
        }
    },

    /**
     * PUT /api/notifications/:id/read
     * Mark a notification as read
     */
    async markAsRead(req: Request, res: Response): Promise<void> {
        try {
            const { id } = req.params;

            if (!id) {
                res.status(400).json({
                    success: false,
                    error: {
                        message: 'Notification ID is required',
                        code: 'VALIDATION_ERROR'
                    }
                } as ErrorResponse);
                return;
            }

            await NotificationRepository.markAsRead(id);

            const response: SuccessResponse = {
                success: true,
                data: { id, isRead: true },
                message: 'Notification marked as read'
            };

            res.status(200).json(response);
        } catch (error: any) {
            console.error('Error in markAsRead:', error);
            res.status(500).json({
                success: false,
                error: {
                    message: error.message || 'Failed to update notification',
                    code: 'UPDATE_ERROR'
                }
            } as ErrorResponse);
        }
    }
};
