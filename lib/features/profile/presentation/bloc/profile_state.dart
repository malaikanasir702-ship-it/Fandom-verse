import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> user;
  final List<Map<String, dynamic>> orders;
  final int bookmarksCount;
  final int wishlistCount;
  final int discussionCount;
  final String? statusMessage;
  final int offlinePostsCount;
  final int offlineEventsCount;
  final int offlineGlossaryCount;
  final double cacheSizeMB;
  final List<String> likedFandoms;

  const ProfileLoaded({
    required this.user,
    required this.orders,
    this.bookmarksCount = 0,
    this.wishlistCount = 0,
    this.discussionCount = 0,
    this.statusMessage,
    this.offlinePostsCount = 0,
    this.offlineEventsCount = 0,
    this.offlineGlossaryCount = 0,
    this.cacheSizeMB = 0.0,
    this.likedFandoms = const [],
  });

  ProfileLoaded copyWith({
    Map<String, dynamic>? user,
    List<Map<String, dynamic>>? orders,
    int? bookmarksCount,
    int? wishlistCount,
    int? discussionCount,
    String? statusMessage,
    int? offlinePostsCount,
    int? offlineEventsCount,
    int? offlineGlossaryCount,
    double? cacheSizeMB,
    List<String>? likedFandoms,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      orders: orders ?? this.orders,
      bookmarksCount: bookmarksCount ?? this.bookmarksCount,
      wishlistCount: wishlistCount ?? this.wishlistCount,
      discussionCount: discussionCount ?? this.discussionCount,
      statusMessage: statusMessage ?? this.statusMessage,
      offlinePostsCount: offlinePostsCount ?? this.offlinePostsCount,
      offlineEventsCount: offlineEventsCount ?? this.offlineEventsCount,
      offlineGlossaryCount: offlineGlossaryCount ?? this.offlineGlossaryCount,
      cacheSizeMB: cacheSizeMB ?? this.cacheSizeMB,
      likedFandoms: likedFandoms ?? this.likedFandoms,
    );
  }

  @override
  List<Object?> get props => [
        user,
        orders,
        bookmarksCount,
        wishlistCount,
        discussionCount,
        statusMessage,
        offlinePostsCount,
        offlineEventsCount,
        offlineGlossaryCount,
        cacheSizeMB,
        likedFandoms,
      ];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
