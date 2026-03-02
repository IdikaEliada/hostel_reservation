// File generated/maintained for Firebase options.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
static FirebaseOptions get currentPlatform {
if (kIsWeb) {
return web;
}
switch (defaultTargetPlatform) {
case TargetPlatform.android:
return android;
case TargetPlatform.iOS:
return ios;
case TargetPlatform.macOS:
throw UnsupportedError(
'DefaultFirebaseOptions have not been configured for macos - '
'run flutterfire configure again.',
);
case TargetPlatform.windows:
throw UnsupportedError(
'DefaultFirebaseOptions have not been configured for windows - '
'run flutterfire configure again.',
);
case TargetPlatform.linux:
// Linux desktop Firebase is not configured in your project.
throw UnsupportedError(
'DefaultFirebaseOptions have not been configured for linux - '
'run flutterfire configure again.',
);
default:
throw UnsupportedError(
'DefaultFirebaseOptions are not supported for this platform.',
);
}
}

/// Web config (also used for web builds).
/// NOTE: Put your actual web values here OR keep placeholders if you’re not using web.
static const FirebaseOptions web = FirebaseOptions(
apiKey: 'REPLACE_WITH_WEB_API_KEY',
appId: 'REPLACE_WITH_WEB_APP_ID',
messagingSenderId: 'REPLACE_WITH_WEB_SENDER_ID',
projectId: 'hostelreservation-1defd',
authDomain: 'hostelreservation-1defd.firebaseapp.com',
storageBucket: 'hostelreservation-1defd.firebasestorage.app',
);

static const FirebaseOptions android = FirebaseOptions(
apiKey: 'AIzaSyBTtBA1E8z9GxGYZQ2b0T2JmmS8JcFZtjw',
appId: '1:1053110957892:android:3f62ad94a8ad058499c911',
messagingSenderId: '1053110957892',
projectId: 'hostelreservation-1defd',
storageBucket: 'hostelreservation-1defd.firebasestorage.app',
);

static const FirebaseOptions ios = FirebaseOptions(
apiKey: 'AIzaSyAOezQy9yhjkRcG4cN6l7pY-Rhpd2YsrJQ',
appId: '1:1053110957892:ios:ba555077fb32c3bd99c911',
messagingSenderId: '1053110957892',
projectId: 'hostelreservation-1defd',
storageBucket: 'hostelreservation-1defd.firebasestorage.app',
iosBundleId: 'com.example.hostelReservation',
);
}
