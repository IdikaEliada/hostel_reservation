import { Router } from 'express';
import { NotificationController } from '../controllers/NotificationController';

const router = Router();

/**
 * @route   POST /api/notifications/send
 * @desc    Send a notification to a user
 * @access  Public (should add authentication in production)
 */
router.post('/send', NotificationController.sendNotification);

/**
 * @route   GET /api/notifications/:userId
 * @desc    Get all notifications for a specific user
 * @access  Public (should add authentication in production)
 */
router.get('/:userId', NotificationController.getUserNotifications);

/**
 * @route   GET /api/notifications/detail/:id
 * @desc    Get a specific notification by ID
 * @access  Public (should add authentication in production)
 */
router.get('/detail/:id', NotificationController.getNotificationById);

/**
 * @route   PUT /api/notifications/:id/read
 * @desc    Mark a notification as read
 * @access  Public (should add authentication in production)
 */
router.put('/:id/read', NotificationController.markAsRead);

export default router;
