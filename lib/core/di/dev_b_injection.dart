import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../database/sqlite_helper.dart';
import '../services/local_storage_service.dart';
import '../theme/bloc/theme_bloc.dart';
import '../repositories/i_store_repository.dart';
import '../repositories/store_repository_impl.dart';
import '../repositories/i_cart_repository.dart';
import '../repositories/cart_repository_impl.dart';
import '../repositories/i_admin_repository.dart';
import '../repositories/admin_repository_impl.dart';
import '../../features/store/presentation/bloc/store_bloc.dart';
import '../../features/cart_checkout/presentation/bloc/cart_bloc.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/admin/presentation/bloc/admin_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> initDevBInjection(GetIt sl) async {
  // ── Initialize SQLite safely — must not crash the app ──────────────────────
  try {
    await SqliteHelper.instance.initDatabase();
    debugPrint('✅ [DevB] SQLite initialized.');
  } catch (e) {
    debugPrint('⚠️ [DevB] SQLite init failed (non-fatal): $e');
  }

  final dbHelper = SqliteHelper.instance;
  SharedPreferences sharedPrefs;

  try {
    sharedPrefs = await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint('⚠️ [DevB] SharedPreferences init failed: $e');
    sharedPrefs = await SharedPreferences.getInstance(); // retry once
  }

  // ── Register services ──────────────────────────────────────────────────────
  if (!sl.isRegistered<SqliteHelper>()) {
    sl.registerLazySingleton<SqliteHelper>(() => dbHelper);
  }
  if (!sl.isRegistered<LocalStorageService>()) {
    sl.registerLazySingleton<LocalStorageService>(
      () => LocalStorageService(sharedPrefs),
    );
  }

  // ── Repositories ───────────────────────────────────────────────────────────
  if (!sl.isRegistered<IStoreRepository>()) {
    sl.registerLazySingleton<IStoreRepository>(
      () => StoreRepositoryImpl(dbHelper: dbHelper),
    );
  }
  if (!sl.isRegistered<ICartRepository>()) {
    sl.registerLazySingleton<ICartRepository>(
      () => CartRepositoryImpl(dbHelper: dbHelper),
    );
  }
  if (!sl.isRegistered<IAdminRepository>()) {
    sl.registerLazySingleton<IAdminRepository>(
      () => AdminRepositoryImpl(dbHelper: dbHelper),
    );
  }

  // ── BLoCs — ThemeBloc MUST always be registered ───────────────────────────
  if (!sl.isRegistered<ThemeBloc>()) {
    sl.registerLazySingleton<ThemeBloc>(
      () => ThemeBloc(sl<LocalStorageService>()),
    );
  }
  if (!sl.isRegistered<StoreBloc>()) {
    sl.registerFactory<StoreBloc>(
      () => StoreBloc(repository: sl<IStoreRepository>()),
    );
  }
  if (!sl.isRegistered<CartBloc>()) {
    sl.registerFactory<CartBloc>(
      () => CartBloc(repository: sl<ICartRepository>()),
    );
  }
  if (!sl.isRegistered<ProfileBloc>()) {
    sl.registerFactory<ProfileBloc>(
      () => ProfileBloc(dbHelper: sl<SqliteHelper>()),
    );
  }
  if (!sl.isRegistered<AdminBloc>()) {
    sl.registerFactory<AdminBloc>(
      () => AdminBloc(repository: sl<IAdminRepository>()),
    );
  }

  debugPrint('✅ [DevB] All dependencies registered.');
}
