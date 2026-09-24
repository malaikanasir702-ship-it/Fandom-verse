import 'package:get_it/get_it.dart';
import '../services/firebase_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import 'dev_a_injection.dart';
import 'dev_b_injection.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // Safe Firebase Initialization with fallback
  await FirebaseService.initialize();

  // Register Firebase Services
  sl.registerLazySingleton<FirebaseAuthService>(() => FirebaseAuthService());
  sl.registerLazySingleton<FirestoreService>(() => FirestoreService());

  // Developer A (Fan side dependencies)
  initDevADependencies(sl);

  // Developer B (Database, Store, Cart, Admin & Theme dependencies)
  await initDevBInjection(sl);
}
