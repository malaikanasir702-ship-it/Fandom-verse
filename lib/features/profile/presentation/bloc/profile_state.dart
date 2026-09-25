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

  const ProfileLoaded({
    required this.user,
    required this.orders,
    this.bookmarksCount = 0,
    this.wishlistCount = 0,
    this.discussionCount = 0,
    this.statusMessage,
  });

  @override
  List<Object?> get props => [
        user,
        orders,
        bookmarksCount,
        wishlistCount,
        discussionCount,
        statusMessage,
      ];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
