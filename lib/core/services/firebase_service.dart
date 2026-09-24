import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  /// Initializes Firebase safely with graceful fallback.
  /// If google-services.json is not yet added, the app will continue
  /// running in offline/seeded mode without crashing.
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _isInitialized = true;
      debugPrint('🔥 [FirebaseService] Firebase successfully initialized.');
    } catch (e) {
      _isInitialized = false;
      debugPrint(
        '⚠️ [FirebaseService] Firebase initialization skipped or failed: $e.\n'
        'Running in offline/local mock mode. To connect live Firebase, download '
        'google-services.json into android/app/ and configure Firebase Console.',
      );
    }
  }
}
