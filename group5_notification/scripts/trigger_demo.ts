/**
 * Manual Test Script
 * Usage: 
 * 1. Start the server in one terminal: npm run dev
 * 2. Run this script in another terminal: npx ts-node scripts/trigger_demo.ts
 */

import axios from 'axios';
import { db } from '../src/config/firebase';

const API_URL = 'http://localhost:3000/api/v1';

// New: Helper to ensure user exists
async function setupTestUser(userId: string) {
    console.log(`👤 Setting up test user: ${userId}...`);
    // We use the direct Firebase Admin SDK to ensure the user exists
    await db.collection('users').doc(userId).set({
        email: 'chinyeakaprosper2006@gmail.com',
        phoneNumber: '+2348165121933',
        createdAt: new Date()
    }, { merge: true });
    console.log('User ready.');
}

async function runDemo() {
    try {
        const userId = 'user-123';
        await setupTestUser(userId);

        console.log(' Triggering Notification...');

        // 1. Trigger a Payment Success Event
        const response = await axios.post(`${API_URL}/trigger-notification`, {
            userId: userId,
            event: 'PAYMENT_SUCCESS', // Must match EVENTS keys
            payload: {
                amount: '$500.00',
                referenceId: 'TXN-998877'
            }
        });

        console.log(' Trigger Response:', response.data);

        // 2. Fetch Notifications for that user (Simulating In-App fetch)
        console.log('\n Fetching User Notifications...');
        const listResponse = await axios.get(`${API_URL}/notifications?userId=user-123`);
        console.log(' User Notifications:', JSON.stringify(listResponse.data, null, 2));

    } catch (error: any) {
        if (error.code === 'ECONNREFUSED') {
            console.error(' Error: Could not connect to server. Make sure "npm run dev" is running!');
        } else {
            console.error(' Error:', error.response?.data || error.message);
        }
    }
}

runDemo();
