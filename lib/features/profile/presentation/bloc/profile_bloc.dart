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
      // Query logged-in user from SQLite by real userId
      final users = await _dbHelper.query(
        DbConstants.tableUsers,
        where: 'user_id = ?',
        whereArgs: [event.userId],
      );

      if (users.isEmpty) {
        emit(const ProfileError('User profile not found. Please log in again.'));
        return;
      }

      final user = users.first;

      // Real counts from DB
      final orders = await _dbHelper.getUserOrders(event.userId);
      final wishes = await _dbHelper.getWishlist(event.userId);

      // Real bookmarks count from posts table
      final bookmarkedPosts = await _dbHelper.query(
        DbConstants.tablePosts,
        where: 'is_bookmarked = 1',
      );

      // Real discussion count for this user
      final discussions = await _dbHelper.query(
        DbConstants.tableDiscussions,
        where: 'user_id = ?',
        whereArgs: [event.userId],
      );

      // Offline content counts (all locally cached data)
      final allPosts = await _dbHelper.query(DbConstants.tablePosts);
      final allEvents = await _dbHelper.query(DbConstants.tableEvents);
      final allGlossary = await _dbHelper.query(DbConstants.tableGlossary);
      final cacheSizeMB = await _dbHelper.calculateCacheSizeMB();

      emit(ProfileLoaded(
        user: user,
        orders: orders,
        wishlistCount: wishes.length,
        bookmarksCount: bookmarkedPosts.length,
        discussionCount: discussions.length,
        offlinePostsCount: allPosts.length,
        offlineEventsCount: allEvents.length,
        offlineGlossaryCount: allGlossary.length,
        cacheSizeMB: cacheSizeMB,
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
        'selected_fandoms': event.selectedFandoms.toString(),
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
      if (state is ProfileLoaded) {
        final current = state as ProfileLoaded;
        emit(ProfileLoaded(
          user: current.user,
          orders: current.orders,
          bookmarksCount: 0,
          wishlistCount: current.wishlistCount,
          discussionCount: current.discussionCount,
          offlinePostsCount: 0,
          offlineEventsCount: 0,
          offlineGlossaryCount: 0,
          cacheSizeMB: 0.0,
          statusMessage: 'Cache cleared successfully!',
        ));
      }
    } catch (_) {}
  }
}
