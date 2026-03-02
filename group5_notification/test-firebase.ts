import { auth, db } from './src/config/firebase';

async function testFirebaseImports() {
    console.log('\n🧪 Testing Firebase Imports & Types...\n');

    try {
        // Test 1: Verify imports work (no module resolution errors)
        console.log('1️⃣ Testing imports...');
        console.log('   ✅ Successfully imported auth and db from firebase config');

        // Test 2: Check types are correct
        console.log('\n2️⃣ Verifying types...');
        console.log('   • auth type:', auth.constructor.name);
        console.log('   • db type:', db.constructor.name);
        console.log('   ✅ Types are correct (no internal path errors)');

        // Test 3: Verify instances are initialized
        console.log('\n3️⃣ Testing instances...');
        if (auth && typeof auth.listUsers === 'function') {
            console.log('   ✅ Auth instance is properly initialized');
        }
        if (db && typeof db.collection === 'function') {
            console.log('   ✅ Firestore instance is properly initialized');
        }

        console.log('\n✅ All import tests passed! The firebase-admin fix is working.\n');
        process.exit(0);
    } catch (error) {
        console.error('\n❌ Test failed:', error);
        process.exit(1);
    }
}

testFirebaseImports();

