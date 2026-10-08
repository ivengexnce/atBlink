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
    apiKey: 'AIzaSyDemoKeyAtBlinkProjectForWeb1234567',
    appId: '1:100200300400:web:atblinkdemo123456789',
    messagingSenderId: '100200300400',
    projectId: 'atblink-app-store',
    authDomain: 'atblink-app-store.firebaseapp.com',
    storageBucket: 'atblink-app-store.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyAtBlinkProjectAndroid12345',
    appId: '1:100200300400:android:atblinkdemo1234567',
    messagingSenderId: '100200300400',
    projectId: 'atblink-app-store',
    storageBucket: 'atblink-app-store.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyAtBlinkProjectIOS1234567',
    appId: '1:100200300400:ios:atblinkdemo123456789',
    messagingSenderId: '100200300400',
    projectId: 'atblink-app-store',
    storageBucket: 'atblink-app-store.appspot.com',
    iosBundleId: 'com.atblink.atblink',
  );
}
