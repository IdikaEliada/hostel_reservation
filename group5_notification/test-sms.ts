/**
 * Direct SMS Test
 * This script tests the SMS service directly to diagnose issues
 */

import { SmsService } from './src/services/ChannelServices';
import * as dotenv from 'dotenv';

dotenv.config();

async function testSMS() {
    console.log('\n📱 Testing SMS Service Directly...\n');

    const phoneNumber = '+2348165121933';
    const message = 'Test SMS from notification backend. If you receive this, SMS is working!';

    console.log(`Phone: ${phoneNumber}`);
    console.log(`Message: ${message}`);
    console.log(`Termii API Key: ${process.env.TERMII_API_KEY ? '✅ Set' : '❌ Not set'}`);
    console.log(`Termii Sender ID: ${process.env.TERMII_SENDER_ID || 'HostelApp'}\n`);

    try {
        const result = await SmsService.send(phoneNumber, message);

        if (result) {
            console.log('\n✅ SMS test completed successfully!');
            console.log('Check your phone for the message.');
        } else {
            console.log('\n❌ SMS test failed!');
            console.log('Check the error messages above for details.');
        }
    } catch (error: any) {
        console.error('\n❌ Error during SMS test:', error.message);
        console.error('Full error:', error.response?.data || error);
    }
}

testSMS();
