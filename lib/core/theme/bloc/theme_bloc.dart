import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/local_storage_service.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final LocalStorageService _storageService;

  ThemeBloc(this._storageService)
      : super(ThemeState(themeMode: _storageService.getThemeMode())) {
    on<LoadSavedThemeEvent>(_onLoadSavedTheme);
    on<ToggleThemeModeEvent>(_onToggleThemeMode);
  }

  void _onLoadSavedTheme(
    LoadSavedThemeEvent event,
    Emitter<ThemeState> emit,
  ) {
    final mode = _storageService.getThemeMode();
    emit(ThemeState(themeMode: mode));
  }

  Future<void> _onToggleThemeMode(
    ToggleThemeModeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    await _storageService.saveThemeMode(event.themeMode);
    emit(ThemeState(themeMode: event.themeMode));
  }
}
