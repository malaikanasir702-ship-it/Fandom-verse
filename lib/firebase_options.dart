// File generated for FandomVerse Firebase configuration.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC2xLKBVzlNUWsKsJcKxkv_jlYgK8iAKAs',
    appId: '1:987727308455:android:7d40ee6c8ff1615f05dd82',
    messagingSenderId: '987727308455',
    projectId: 'fandom-verse-e3024',
    storageBucket: 'fandom-verse-e3024.firebasestorage.app',
  );
}
