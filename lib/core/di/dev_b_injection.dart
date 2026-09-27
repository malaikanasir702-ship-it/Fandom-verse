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
  // ── Performance: Run SQLite init and SharedPreferences in parallel ──
  final results = await Future.wait([
    SqliteHelper.instance.initDatabase(),
    SharedPreferences.getInstance(),
  ]);

  final dbHelper = SqliteHelper.instance;
  final sharedPrefs = results[1] as SharedPreferences;

  sl.registerLazySingleton<SqliteHelper>(() => dbHelper);
  sl.registerLazySingleton<LocalStorageService>(
    () => LocalStorageService(sharedPrefs),
  );

  // Repositories (Dev B)
  sl.registerLazySingleton<IStoreRepository>(
    () => StoreRepositoryImpl(dbHelper: dbHelper),
  );
  sl.registerLazySingleton<ICartRepository>(
    () => CartRepositoryImpl(dbHelper: dbHelper),
  );
  sl.registerLazySingleton<IAdminRepository>(
    () => AdminRepositoryImpl(dbHelper: dbHelper),
  );

  // BLoCs — registerFactory for short-lived, registerLazySingleton for global
  sl.registerLazySingleton<ThemeBloc>(
    () => ThemeBloc(sl<LocalStorageService>()),
  );
  sl.registerFactory<StoreBloc>(
    () => StoreBloc(repository: sl<IStoreRepository>()),
  );
  sl.registerFactory<CartBloc>(
    () => CartBloc(repository: sl<ICartRepository>()),
  );
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(dbHelper: sl<SqliteHelper>()),
  );
  sl.registerFactory<AdminBloc>(
    () => AdminBloc(repository: sl<IAdminRepository>()),
  );
}
