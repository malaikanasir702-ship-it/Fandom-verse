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
        const Duration(seconds: 15),
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
      try {
        await Firebase.initializeApp().timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw TimeoutException('Firebase native init timed out.'),
        );
        _isInitialized = true;
        debugPrint('🔥 [FirebaseService] Firebase initialized via native configuration.');
      } on TimeoutException catch (e2) {
        _isInitialized = false;
        debugPrint('⚠️ [FirebaseService] Firebase init timed out: $e2\nRunning in offline/local mode.');
      } on SocketException catch (e2) {
        _isInitialized = false;
        debugPrint('⚠️ [FirebaseService] Network error: $e2\nRunning in offline/local mode.');
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
