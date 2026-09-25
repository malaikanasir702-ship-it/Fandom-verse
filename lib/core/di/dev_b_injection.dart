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
  // Real SQLite Database (sqflite)
  final dbHelper = SqliteHelper.instance;
  await dbHelper.initDatabase();
  sl.registerLazySingleton<SqliteHelper>(() => dbHelper);

  // SharedPreferences for theme persistence only
  final sharedPrefs = await SharedPreferences.getInstance();
  final localStorageService = LocalStorageService(sharedPrefs);
  sl.registerLazySingleton<LocalStorageService>(() => localStorageService);

  // Repositories (Dev B)
  sl.registerLazySingleton<IStoreRepository>(() => StoreRepositoryImpl(dbHelper: dbHelper));
  sl.registerLazySingleton<ICartRepository>(() => CartRepositoryImpl(dbHelper: dbHelper));
  sl.registerLazySingleton<IAdminRepository>(() => AdminRepositoryImpl(dbHelper: dbHelper));

  // BLoCs
  sl.registerLazySingleton<ThemeBloc>(() => ThemeBloc(sl<LocalStorageService>()));
  sl.registerFactory<StoreBloc>(() => StoreBloc(repository: sl<IStoreRepository>()));
  sl.registerFactory<CartBloc>(() => CartBloc(repository: sl<ICartRepository>()));
  sl.registerFactory<ProfileBloc>(() => ProfileBloc(dbHelper: sl<SqliteHelper>()));
  sl.registerFactory<AdminBloc>(() => AdminBloc(repository: sl<IAdminRepository>()));
}
