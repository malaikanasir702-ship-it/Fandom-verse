import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';

class FirebaseService {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized || Firebase.apps.isNotEmpty;

  /// Initializes Firebase safely with graceful fallback.
  /// A 15-second timeout prevents the app from hanging on network errors
  /// (e.g. wsarecv timeouts, SocketExceptions) at startup.
  static Future<void> initialize() async {
    if (Firebase.apps.isNotEmpty) {
      _isInitialized = true;
      debugPrint('🔥 [FirebaseService] Firebase already initialized.');
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(
        const Duration(milliseconds: 3500),
        onTimeout: () => throw TimeoutException(
          'Firebase initialization timed out. Running in offline mode.',
        ),
      );
      _isInitialized = true;
      debugPrint('🔥 [FirebaseService] Firebase successfully initialized with DefaultFirebaseOptions.');
    } on TimeoutException catch (e) {
      _isInitialized = false;
      debugPrint('⚠️ [FirebaseService] $e\nRunning in offline/local mode.');
    } on SocketException catch (e) {
      _isInitialized = false;
      debugPrint('⚠️ [FirebaseService] Network unavailable: $e\nRunning in offline/local mode.');
    } catch (e) {
      // Single fallback attempt with short 1.5s timeout
      try {
        await Firebase.initializeApp().timeout(
          const Duration(milliseconds: 1500),
        );
        _isInitialized = true;
        debugPrint('🔥 [FirebaseService] Firebase initialized via native configuration.');
      } catch (e2) {
        _isInitialized = false;
        debugPrint(
          '⚠️ [FirebaseService] Firebase initialization failed or timed out: $e | $e2.\n'
          'Running in offline/local mock mode.',
        );
      }
    }
  }
}
