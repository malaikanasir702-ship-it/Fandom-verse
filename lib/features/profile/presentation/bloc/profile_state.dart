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
  final double cacheSizeMB;
  final int bookmarksCount;
  final int wishlistCount;
  final int triviaXp;
  final String? statusMessage;

  const ProfileLoaded({
    required this.user,
    required this.orders,
    required this.cacheSizeMB,
    this.bookmarksCount = 14,
    this.wishlistCount = 5,
    this.triviaXp = 280,
    this.statusMessage,
  });

  @override
  List<Object?> get props => [
        user,
        orders,
        cacheSizeMB,
        bookmarksCount,
        wishlistCount,
        triviaXp,
        statusMessage,
      ];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
