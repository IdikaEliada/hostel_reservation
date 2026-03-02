import { v4 as uuidv4 } from 'uuid';
import {
SendNotificationRequest,
NotificationRecord,
NotificationChannel,
} from '../models/Notification';
import { EVENT_CONFIGS } from '../models/Events';
import { getTemplate, renderTemplate } from '../templates/TemplateManager';
import { NotificationRepository } from '../repositories/NotificationRepository';
import { EmailService, SmsService } from './ChannelServices';
import { db } from '../config/firebase';
import admin from 'firebase-admin';

const getUserContact = async (userId: string) => {
const userDoc = await db.collection('users').doc(userId).get();
if (!userDoc.exists) return null;
return userDoc.data() as {
email: string;
phoneNumber: string;
fcmToken?: string;
};
};

// ✅ Will try users/{userId}.fcmToken first, then user_tokens/{userId}.token
const getFcmTokenForUser = async (userId: string): Promise<string | null> => {
const userDoc = await db.collection('users').doc(userId).get();
const userData = userDoc.exists ? (userDoc.data() as any) : null;
if (userData?.fcmToken) return userData.fcmToken;

const tokenDoc = await db.collection('user_tokens').doc(userId).get();
if (!tokenDoc.exists) return null;

const token = tokenDoc.data()?.token;
return token || null;
};

const sendPushToUser = async (
userId: string,
title: string,
body: string,
data: Record<string, any> = {}
): Promise<boolean> => {
const token = await getFcmTokenForUser(userId);

if (!token) {
console.log(`⚠️ No FCM token for user ${userId}`);
return false;
}

await admin.messaging().send({
token,
notification: { title, body },
data: Object.fromEntries(
Object.entries(data).map(([k, v]) => [k, String(v)])
),
});

console.log(`✅ Push sent to ${userId}`);
return true;
};

export const NotificationService = {
async sendNotification({
userId,
event,
payload,
idempotencyKey,
}: SendNotificationRequest): Promise<void> {
const config = EVENT_CONFIGS[event];
if (!config) {
throw new Error(`Invalid event type: ${event}`);
}

const user = await getUserContact(userId);
if (!user) {
console.error(`User not found: ${userId}`);
return;
}

const templateSet = getTemplate(event);

// ✅ Added "push"
const channels: NotificationChannel[] = ['email', 'sms', 'in_app', 'push'];

const records: NotificationRecord[] = channels.map((channel) => {
// ✅ fallback so push won't crash if you don't have push template yet
const tpl = (templateSet as any)[channel] ?? (templateSet as any)['in_app'];

const content = renderTemplate(tpl.body, payload);
const title = tpl.subject ? renderTemplate(tpl.subject, payload) : '';

const baseKey = idempotencyKey || `${userId}_${event}_${Date.now()}`;
const uniqueKey = `${baseKey}_${channel}`;

return {
id: uuidv4(),
userId,
event,
type: config.type,
channel,
title: title,
message: content,
priority: config.priority,
status: 'pending',
isRead: false,
idempotencyKey: uniqueKey,
metadata: payload,
createdAt: new Date(),
};
});

await Promise.all(records.map((r) => NotificationRepository.create(r)));

records.forEach(async (record) => {
try {
if (record.channel === 'email') {
if (user.email) {
const sent = await EmailService.send(
user.email,
record.message,
record.title
);
await NotificationRepository.updateStatus(
record.idempotencyKey,
sent ? 'sent' : 'failed'
);
} else {
await NotificationRepository.updateStatus(
record.idempotencyKey,
'failed',
'No Email'
);
}
} else if (record.channel === 'sms') {
if (user.phoneNumber) {
const sent = await SmsService.send(user.phoneNumber, record.message);
await NotificationRepository.updateStatus(
record.idempotencyKey,
sent ? 'sent' : 'failed'
);
} else {
await NotificationRepository.updateStatus(
record.idempotencyKey,
'failed',
'No Phone'
);
}
} else if (record.channel === 'in_app') {
await NotificationRepository.updateStatus(record.idempotencyKey, 'sent');
} else if (record.channel === 'push') {
const sent = await sendPushToUser(
record.userId,
record.title || 'Notification',
record.message || '',
(record.metadata as any) || {}
);

await NotificationRepository.updateStatus(
record.idempotencyKey,
sent ? 'sent' : 'failed',
sent ? undefined : 'No FCM token'
);
}
} catch (err: any) {
console.error(
`Failed to send ${record.channel} for ${record.idempotencyKey}`,
err
);
await NotificationRepository.updateStatus(
record.idempotencyKey,
'failed',
err.message
);
}
});
},
};

