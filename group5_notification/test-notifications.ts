import axios from 'axios';
import { db } from './src/config/firebase';

/**
 * Comprehensive Notification Backend Test Suite
 * 
 * Tests email (SendGrid) and SMS (Termii) delivery
 */

const API_BASE_URL = 'http://localhost:3000';
const TEST_USER_ID = 'test-user-001';

// Color codes for terminal output
const colors = {
    reset: '\x1b[0m',
    green: '\x1b[32m',
    red: '\x1b[31m',
    yellow: '\x1b[33m',
    blue: '\x1b[36m',
};

function log(message: string, color: keyof typeof colors = 'reset') {
    console.log(`${colors[color]}${message}${colors.reset}`);
}

async function sleep(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function testHealthCheck() {
    log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', 'blue');
    log('TEST 1: Health Check', 'blue');
    log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n', 'blue');

    try {
        const response = await axios.get(`${API_BASE_URL}/health`);
        log('✅ Server is running', 'green');
        console.log('   Response:', response.data);
        return true;
    } catch (error: any) {
        log('❌ Server is not running or unreachable', 'red');
        console.log('   Error:', error.message);
        return false;
    }
}

async function testSendNotification(event: string, payload: any) {
    log(`\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`, 'blue');
    log(`TEST: Sending ${event} notification`, 'blue');
    log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n', 'blue');

    try {
        const response = await axios.post(`${API_BASE_URL}/api/notifications/send`, {
            userId: TEST_USER_ID,
            event: event,
            payload: payload,
            idempotencyKey: `test_${event}_${Date.now()}`
        });

        log('✅ Notification API call successful', 'green');
        console.log('   Response:', JSON.stringify(response.data, null, 2));

        // Wait a bit for async processing
        log('\n⏳ Waiting 3 seconds for notification processing...', 'yellow');
        await sleep(3000);

        return true;
    } catch (error: any) {
        log('❌ Failed to send notification', 'red');
        console.log('   Error:', error.response?.data || error.message);
        return false;
    }
}

async function checkNotificationsInFirestore() {
    log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', 'blue');
    log('TEST: Checking Notifications in Firestore', 'blue');
    log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n', 'blue');

    try {
        const snapshot = await db.collection('notifications')
            .where('userId', '==', TEST_USER_ID)
            .limit(10)
            .get();

        if (snapshot.empty) {
            log('⚠️  No notifications found in Firestore', 'yellow');
            return false;
        }

        log(`✅ Found ${snapshot.size} notification(s)`, 'green');

        let index = 0;
        snapshot.forEach((doc) => {
            const data = doc.data();
            console.log(`\n   Notification ${index + 1}:`);
            index++;
            console.log(`      ID: ${doc.id}`);
            console.log(`      Event: ${data.event}`);
            console.log(`      Channel: ${data.channel}`);
            console.log(`      Status: ${data.status}`);
            console.log(`      Title: ${data.title}`);
            console.log(`      Created: ${data.createdAt?.toDate?.()}`);
        });

        return true;
    } catch (error: any) {
        log('❌ Failed to query Firestore', 'red');
        console.log('   Error:', error.message);
        return false;
    }
}

async function runAllTests() {
    console.log('\n');
    log('╔═══════════════════════════════════════════════════════════╗', 'blue');
    log('║     NOTIFICATION BACKEND - COMPREHENSIVE TEST SUITE      ║', 'blue');
    log('╚═══════════════════════════════════════════════════════════╝', 'blue');

    let passedTests = 0;
    let totalTests = 0;

    // Test 1: Health Check
    totalTests++;
    if (await testHealthCheck()) passedTests++;

    // Test 2: Welcome Email (User Signup)
    totalTests++;
    if (await testSendNotification('user_signup', {
        userName: 'Test User',
        loginUrl: 'https://yourapp.com/login'
    })) passedTests++;

    // Test 3: Password Reset
    totalTests++;
    if (await testSendNotification('password_reset', {
        userName: 'Test User',
        resetLink: 'https://yourapp.com/reset?token=abc123',
        expiryTime: '1 hour'
    })) passedTests++;

    // Test 4: Booking Confirmation
    totalTests++;
    if (await testSendNotification('booking_confirmation', {
        userName: 'Test User',
        hostelName: 'Elite Hostel',
        roomNumber: 'A-101',
        bookingDate: new Date().toLocaleDateString(),
        checkInDate: new Date().toLocaleDateString(),
        amount: '₦50,000'
    })) passedTests++;

    // Test 5: Check Firestore
    totalTests++;
    if (await checkNotificationsInFirestore()) passedTests++;

    // Summary
    log('\n\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', 'blue');
    log('TEST SUMMARY', 'blue');
    log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n', 'blue');

    console.log(`   Total Tests: ${totalTests}`);
    log(`   Passed: ${passedTests}`, passedTests === totalTests ? 'green' : 'yellow');
    log(`   Failed: ${totalTests - passedTests}`, totalTests === passedTests ? 'green' : 'red');

    log('\n📧 MANUAL VERIFICATION REQUIRED:', 'yellow');
    log('   1. Check your EMAIL inbox for test emails', 'yellow');
    log('   2. Check your PHONE for test SMS messages', 'yellow');
    log('   3. Check your server logs for delivery confirmations\n', 'yellow');

    process.exit(passedTests === totalTests ? 0 : 1);
}

runAllTests();
