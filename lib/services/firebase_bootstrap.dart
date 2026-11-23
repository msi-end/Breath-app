import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../config/firebase_options.dart';

/// Initialises Firebase when it has been configured. The app never depends on
/// Firebase for its core, offline features.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool available = false;

  static Future<void> init() async {
    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      if (options.apiKey.startsWith('REPLACE')) {
        debugPrint('Firebase not configured — cloud features disabled.');
        return;
      }
      await Firebase.initializeApp(options: options).timeout(const Duration(seconds: 10));
      available = true;
    } catch (e) {
      debugPrint('Firebase unavailable: $e');
      available = false;
    }
  }
}
