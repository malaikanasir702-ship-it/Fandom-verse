import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/sqlite_helper.dart';
import '../services/local_storage_service.dart';
import '../theme/bloc/theme_bloc.dart';
import '../../features/store/presentation/bloc/store_bloc.dart';
import '../../features/cart_checkout/presentation/bloc/cart_bloc.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/admin/presentation/bloc/admin_bloc.dart';

Future<void> initDevBInjection(GetIt sl) async {
  // SQLite Database & Local Storage
  final dbHelper = SqliteHelper.instance;
  await dbHelper.initDatabase();
  sl.registerLazySingleton<SqliteHelper>(() => dbHelper);

  final sharedPrefs = await SharedPreferences.getInstance();
  final localStorageService = LocalStorageService(sharedPrefs);
  sl.registerLazySingleton<LocalStorageService>(() => localStorageService);

  // Blocs
  sl.registerFactory<ThemeBloc>(() => ThemeBloc(sl<LocalStorageService>()));
  sl.registerFactory<StoreBloc>(() => StoreBloc(dbHelper: sl<SqliteHelper>()));
  sl.registerFactory<CartBloc>(() => CartBloc(dbHelper: sl<SqliteHelper>()));
  sl.registerFactory<ProfileBloc>(() => ProfileBloc(dbHelper: sl<SqliteHelper>()));
  sl.registerFactory<AdminBloc>(() => AdminBloc(dbHelper: sl<SqliteHelper>()));
}
