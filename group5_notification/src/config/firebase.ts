import * as admin from 'firebase-admin';
import * as path from 'path';

// Initialize Firebase Admin SDK
try {
    const serviceAccountPath = path.join(__dirname, '../../serviceAccountKey.json');
    const serviceAccount = require(serviceAccountPath);

    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        databaseURL: process.env.FIREBASE_DATABASE_URL || `https://${serviceAccount.project_id}.firebaseio.com`
    });

    console.log('✅ Firebase Admin initialized successfully');
} catch (error) {
    console.error('❌ Failed to initialize Firebase Admin:', error);
    throw error;
}

// Export Firestore database instance
export const db = admin.firestore();

// Export auth instance for user management
export const auth: admin.auth.Auth = admin.auth();

// Export the admin instance if needed elsewhere
export default admin;
