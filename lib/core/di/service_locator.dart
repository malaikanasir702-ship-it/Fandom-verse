import 'package:get_it/get_it.dart';
import '../services/firebase_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../services/cloudinary_service.dart';
import 'dev_a_injection.dart';
import 'dev_b_injection.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // Safe Firebase Initialization with fallback
  await FirebaseService.initialize();

  // Register Firebase Services
  if (!sl.isRegistered<FirebaseAuthService>()) {
    sl.registerLazySingleton<FirebaseAuthService>(() => FirebaseAuthService());
  }
  if (!sl.isRegistered<FirestoreService>()) {
    sl.registerLazySingleton<FirestoreService>(() => FirestoreService());
  }

  // Register Cloudinary CDN Service
  if (!sl.isRegistered<CloudinaryService>()) {
    sl.registerLazySingleton<CloudinaryService>(() => CloudinaryService.instance);
  }

  // Initialize FCM — real push notifications (non-blocking, after app starts)
  // NOTE: FCMService.initialize() moved to post-frame in main.dart

  // Developer A (Fan side dependencies)
  initDevADependencies(sl);

  // Developer B (Database, Store, Cart, Admin & Theme dependencies)
  await initDevBInjection(sl);
}
