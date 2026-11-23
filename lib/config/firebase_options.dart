// PLACEHOLDER — regenerate this file with the FlutterFire CLI:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Until then BreatheCare runs fully offline: optional login, cloud backup and
// audio downloads show a "not configured" message, everything else works.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('BreatheCare is configured for Android and iOS only.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('BreatheCare is configured for Android and iOS only.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    appId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    messagingSenderId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    projectId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    storageBucket: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    appId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    messagingSenderId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    projectId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    storageBucket: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    iosBundleId: 'com.breathecare.breathecare',
  );
}
