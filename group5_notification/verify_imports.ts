/**
 * Simple verification script to test that all modules can be imported
 */

import { NotificationService } from './src/services/NotificationService';
import { NotificationRepository } from './src/repositories/NotificationRepository';
import { EmailService, SmsService } from './src/services/ChannelServices';
import { EVENT_CONFIGS } from './src/models/Events';

console.log('✅ All imports successful!');
console.log('✅ NotificationService:', typeof NotificationService);
console.log('✅ NotificationRepository:', typeof NotificationRepository);
console.log('✅ EmailService:', typeof EmailService);
console.log('✅ SmsService:', typeof SmsService);
console.log('✅ EVENT_CONFIGS:', typeof EVENT_CONFIGS);
console.log('\n📊 Available Events:');
Object.keys(EVENT_CONFIGS).forEach(event => {
    console.log(`  - ${event}: ${EVENT_CONFIGS[event as keyof typeof EVENT_CONFIGS].description}`);
});
