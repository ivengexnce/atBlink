import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDwsULySiJWZiiv6vordQ8vZkSgWTTW0Rs',
    appId: '1:1062841587937:web:9d9d9ce13acc889f333fa0',
    messagingSenderId: '1062841587937',
    projectId: 'atblink-meet',
    authDomain: 'atblink-meet.firebaseapp.com',
    storageBucket: 'atblink-meet.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDwsULySiJWZiiv6vordQ8vZkSgWTTW0Rs',
    appId: '1:1062841587937:android:9d9d9ce13acc889f333fa0',
    messagingSenderId: '1062841587937',
    projectId: 'atblink-meet',
    storageBucket: 'atblink-meet.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDwsULySiJWZiiv6vordQ8vZkSgWTTW0Rs',
    appId: '1:1062841587937:ios:9d9d9ce13acc889f333fa0',
    messagingSenderId: '1062841587937',
    projectId: 'atblink-meet',
    storageBucket: 'atblink-meet.firebasestorage.app',
    iosBundleId: 'com.atblink.atblink',
  );
}
