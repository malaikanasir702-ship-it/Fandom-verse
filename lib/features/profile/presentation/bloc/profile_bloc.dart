import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/database/sqlite_helper.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final SqliteHelper _dbHelper;

  ProfileBloc({SqliteHelper? dbHelper})
      : _dbHelper = dbHelper ?? SqliteHelper.instance,
        super(const ProfileInitial()) {
    on<LoadUserProfileEvent>(_onLoadUserProfile);
    on<UpdateProfileDetailsEvent>(_onUpdateProfileDetails);
    on<ClearLocalCacheStorageEvent>(_onClearCache);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final users = await _dbHelper.query(DbConstants.tableUsers);
      final user = users.firstWhere(
        (u) => u['user_id'] == event.userId,
        orElse: () => {
          'user_id': 'fan-01',
          'name': 'Alex Mercer',
          'email': 'fan@fandomverse.com',
          'avatar_url': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400',
          'bio': 'Anime watcher, speedrunner & convention fanatic.',
          'badges': '["Master Lorekeeper", "Con Veteran 2025", "Speedrun Guru"]',
          'selected_fandoms': '["Anime & Manga", "Gaming & Esports"]',
        },
      );

      final orders = await _dbHelper.getUserOrders(event.userId);
      final wishes = await _dbHelper.getWishlist(event.userId);
      final cacheMB = await _dbHelper.calculateCacheSizeMB();

      emit(ProfileLoaded(
        user: user,
        orders: orders,
        cacheSizeMB: cacheMB,
        wishlistCount: wishes.length,
        bookmarksCount: 14,
        triviaXp: 280,
      ));
    } catch (e) {
      emit(ProfileError('Failed to load profile: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProfileDetails(
    UpdateProfileDetailsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _dbHelper.update(DbConstants.tableUsers, 'user_id', event.userId, {
        'name': event.name,
        'bio': event.bio,
        'avatar_url': event.avatarUrl,
      });
      add(LoadUserProfileEvent(userId: event.userId));
    } catch (e) {
      emit(ProfileError('Failed to update profile: ${e.toString()}'));
    }
  }

  Future<void> _onClearCache(
    ClearLocalCacheStorageEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _dbHelper.clearOfflineCache();
      final cacheMB = await _dbHelper.calculateCacheSizeMB();
      if (state is ProfileLoaded) {
        final current = state as ProfileLoaded;
        emit(ProfileLoaded(
          user: current.user,
          orders: current.orders,
          cacheSizeMB: cacheMB,
          bookmarksCount: current.bookmarksCount,
          wishlistCount: current.wishlistCount,
          triviaXp: current.triviaXp,
          statusMessage: 'Offline cache cleared successfully!',
        ));
      }
    } catch (_) {}
  }
}
