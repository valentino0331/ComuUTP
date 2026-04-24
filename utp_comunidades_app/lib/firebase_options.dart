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
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Firebase Web Configuration
  // From Firebase Console → Project Settings → Your apps → Web app
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDVItbv9Hb1Yo2K1E0QhbMlfENH6QL3b34',
    appId: '1:400138742768:web:d491793c672dbfe07f0b35',
    messagingSenderId: '400138742768',
    projectId: 'comunidades-9325c',
    authDomain: 'comunidades-9325c.firebaseapp.com',
    storageBucket: 'comunidades-9325c.firebasestorage.app',
    measurementId: 'G-21WXMT3LEJ',
  );

  // Android uses google-services.json, no need for explicit config
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDRg3wtDrv-8QUo--_wFiAY1qCNMkJlzQE',
    appId: '1:400138742768:android:8b4e3a19597e04987f0b35',
    messagingSenderId: '400138742768',
    projectId: 'comunidades-9325c',
    storageBucket: 'comunidades-9325c.firebasestorage.app',
  );

  // iOS uses GoogleService-Info.plist, no need for explicit config
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'DUMMY_API_KEY',
    appId: 'DUMMY_APP_ID',
    messagingSenderId: 'DUMMY_SENDER_ID',
    projectId: 'DUMMY_PROJECT_ID',
  );
}
