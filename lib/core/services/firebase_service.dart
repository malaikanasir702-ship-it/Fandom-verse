import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';

class FirebaseService {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized || Firebase.apps.isNotEmpty;

  /// Initializes Firebase safely with graceful fallback.
  /// If google-services.json is not yet added, the app will continue
  /// running in offline/seeded mode without crashing.
  static Future<void> initialize() async {
    if (Firebase.apps.isNotEmpty) {
      _isInitialized = true;
      debugPrint('🔥 [FirebaseService] Firebase already initialized.');
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = true;
      debugPrint('🔥 [FirebaseService] Firebase successfully initialized with DefaultFirebaseOptions.');
    } catch (e) {
      try {
        await Firebase.initializeApp();
        _isInitialized = true;
        debugPrint('🔥 [FirebaseService] Firebase initialized via native configuration.');
      } catch (e2) {
        _isInitialized = false;
        debugPrint(
          '⚠️ [FirebaseService] Firebase initialization failed: $e | $e2.\n'
          'Running in offline/local mock mode.',
        );
      }
    }
  }
}
