import { db } from './src/config/firebase';

/**
 * Setup Test User for Notification Testing
 * 
 * This script creates a test user in Firestore with email and phone number
 * so that the notification system can send test emails and SMS messages.
 */

async function setupTestUser() {
    console.log('\n🔧 Setting up test user for notification testing...\n');

    // TODO: Update these values with your real email and phone number
    const testUser = {
        userId: 'test-user-001',
        email: 'obikachibuike15@gmail.com',  // ⚠️ UPDATE THIS with your email
        phoneNumber: '2348088829788',      // ⚠️ UPDATE THIS with your phone (format: +234...)
        name: 'test user',
        createdAt: new Date(),
    };

    // Validation
    if (testUser.email === 'YOUR_EMAIL@example.com' || testUser.phoneNumber === '+234XXXXXXXXXX') {
        console.error('❌ Error: Please update the email and phoneNumber in the script first!');
        console.error('   Open setup-test-user.ts and replace the placeholder values.');
        process.exit(1);
    }

    try {
        // Add user to Firestore
        await db.collection('users').doc(testUser.userId).set(testUser);

        console.log('✅ Test user created successfully!');
        console.log('\n📋 User Details:');
        console.log(`   User ID: ${testUser.userId}`);
        console.log(`   Email: ${testUser.email}`);
        console.log(`   Phone: ${testUser.phoneNumber}`);
        console.log(`   Name: ${testUser.name}`);
        console.log('\n💡 You can now run the notification tests using this user ID.\n');

        process.exit(0);
    } catch (error: any) {
        console.error('❌ Failed to create test user:', error.message);
        process.exit(1);
    }
}

setupTestUser();


