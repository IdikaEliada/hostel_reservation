import { db } from '../config/firebase';
import { NotificationRecord, NotificationStatus } from '../models/Notification';

const COLLECTION_NAME = 'notifications';

export const NotificationRepository = {
    /**
     * Create a new notification record in Firestore
     */
    async create(record: NotificationRecord): Promise<void> {
        try {
            // Check for duplicate using idempotency key
            const existing = await this.getByIdempotencyKey(record.idempotencyKey);
            if (existing) {
                console.log(`Notification with idempotency key ${record.idempotencyKey} already exists. Skipping.`);
                return;
            }

            // Convert Date to Firestore Timestamp
            const firestoreRecord = {
                ...record,
                createdAt: new Date(record.createdAt),
                sentAt: record.sentAt ? new Date(record.sentAt) : null,
                readAt: record.readAt ? new Date(record.readAt) : null
            };

            await db.collection(COLLECTION_NAME).doc(record.id).set(firestoreRecord);
            console.log(`✅ Created notification: ${record.id} for user: ${record.userId}`);
        } catch (error) {
            console.error('Error creating notification:', error);
            throw error;
        }
    },

    /**
     * Update the status of a notification
     */
    async updateStatus(
        idempotencyKey: string,
        status: NotificationStatus,
        errorMessage?: string
    ): Promise<void> {
        try {
            const snapshot = await db.collection(COLLECTION_NAME)
                .where('idempotencyKey', '==', idempotencyKey)
                .limit(1)
                .get();

            if (snapshot.empty) {
                console.warn(`No notification found with idempotency key: ${idempotencyKey}`);
                return;
            }

            const doc = snapshot.docs[0];
            const updateData: any = {
                status,
                ...(errorMessage && { errorMessage }),
                ...(status === 'sent' && { sentAt: new Date() })
            };

            await doc.ref.update(updateData);
            console.log(`✅ Updated notification ${doc.id} status to: ${status}`);
        } catch (error) {
            console.error('Error updating notification status:', error);
            throw error;
        }
    },

    /**
     * Get notification by idempotency key (for duplicate prevention)
     */
    async getByIdempotencyKey(idempotencyKey: string): Promise<NotificationRecord | null> {
        try {
            const snapshot = await db.collection(COLLECTION_NAME)
                .where('idempotencyKey', '==', idempotencyKey)
                .limit(1)
                .get();

            if (snapshot.empty) {
                return null;
            }

            return snapshot.docs[0].data() as NotificationRecord;
        } catch (error) {
            console.error('Error fetching notification by idempotency key:', error);
            throw error;
        }
    },

    /**
     * Get all notifications for a specific user
     */
    async getByUserId(userId: string, limit: number = 50): Promise<NotificationRecord[]> {
        try {
            const snapshot = await db.collection(COLLECTION_NAME)
                .where('userId', '==', userId)
                .orderBy('createdAt', 'desc')
                .limit(limit)
                .get();

            return snapshot.docs.map(doc => doc.data() as NotificationRecord);
        } catch (error) {
            console.error('Error fetching notifications by user ID:', error);
            throw error;
        }
    },

    /**
     * Get all notifications for a specific user with pagination
     */
    async findByUserId(userId: string, limit: number = 50, offset: number = 0): Promise<NotificationRecord[]> {
        try {
            let query = db.collection(COLLECTION_NAME)
                .where('userId', '==', userId)
                .orderBy('createdAt', 'desc')
                .limit(limit);

            if (offset > 0) {
                // For pagination, we'd typically use startAfter with a document snapshot
                // For simplicity, we're using the basic limit approach
                const skipSnapshot = await db.collection(COLLECTION_NAME)
                    .where('userId', '==', userId)
                    .orderBy('createdAt', 'desc')
                    .limit(offset)
                    .get();

                if (!skipSnapshot.empty) {
                    const lastDoc = skipSnapshot.docs[skipSnapshot.docs.length - 1];
                    query = query.startAfter(lastDoc);
                }
            }

            const snapshot = await query.get();
            return snapshot.docs.map(doc => doc.data() as NotificationRecord);
        } catch (error) {
            console.error('Error fetching notifications by user ID:', error);
            throw error;
        }
    },

    /**
     * Get notification by ID
     */
    async findById(id: string): Promise<NotificationRecord | null> {
        try {
            const doc = await db.collection(COLLECTION_NAME).doc(id).get();

            if (!doc.exists) {
                return null;
            }

            return doc.data() as NotificationRecord;
        } catch (error) {
            console.error('Error fetching notification by ID:', error);
            throw error;
        }
    },

    /**
     * Mark a notification as read
     */
    async markAsRead(notificationId: string): Promise<void> {
        try {
            await db.collection(COLLECTION_NAME).doc(notificationId).update({
                isRead: true,
                readAt: new Date()
            });
            console.log(`✅ Marked notification ${notificationId} as read`);
        } catch (error) {
            console.error('Error marking notification as read:', error);
            throw error;
        }
    },

    /**
     * Get unread notification count for a user
     */
    async getUnreadCount(userId: string): Promise<number> {
        try {
            const snapshot = await db.collection(COLLECTION_NAME)
                .where('userId', '==', userId)
                .where('isRead', '==', false)
                .get();

            return snapshot.size;
        } catch (error) {
            console.error('Error getting unread count:', error);
            throw error;
        }
    }
};

