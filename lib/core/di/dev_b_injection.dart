import 'package:get_it/get_it.dart';
import '../database/sqlite_helper.dart';
import '../services/local_storage_service.dart';
import '../theme/bloc/theme_bloc.dart';
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

  // BLoCs
  sl.registerFactory<ThemeBloc>(() => ThemeBloc(sl<LocalStorageService>()));
  sl.registerFactory<StoreBloc>(() => StoreBloc(dbHelper: sl<SqliteHelper>()));
  sl.registerFactory<CartBloc>(() => CartBloc(dbHelper: sl<SqliteHelper>()));
  sl.registerFactory<ProfileBloc>(() => ProfileBloc(dbHelper: sl<SqliteHelper>()));
  sl.registerFactory<AdminBloc>(() => AdminBloc(dbHelper: sl<SqliteHelper>()));
}
