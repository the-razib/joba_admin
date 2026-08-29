import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
        return web;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBBtH-6LzzGmBA55k_rZJ8osziyrfDDy1w',
    appId: '1:366539124119:web:04ba1ec10edfa9f45ea8d2',
    messagingSenderId: '366539124119',
    projectId: 'joba-a913b',
    authDomain: 'joba-a913b.firebaseapp.com',
    storageBucket: 'joba-a913b.firebasestorage.app',
    measurementId: 'G-41PQ25X13X',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBBtH-6LzzGmBA55k_rZJ8osziyrfDDy1w',
    appId: '1:366539124119:android:7f1f87a0b05c3cb45ea8d2',
    messagingSenderId: '366539124119',
    projectId: 'joba-a913b',
    storageBucket: 'joba-a913b.firebasestorage.app',
  );
}
