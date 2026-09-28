import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// ProfileBloc now derives userId from AuthBloc's currentUser.
/// Pass userId explicitly when dispatching events — no more 'fan-01' fallback.
class LoadUserProfileEvent extends ProfileEvent {
  final String userId;
  const LoadUserProfileEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class UpdateProfileDetailsEvent extends ProfileEvent {
  final String userId;
  final String name;
  final String bio;
  final String avatarUrl;
  final List<String> selectedFandoms;

  const UpdateProfileDetailsEvent({
    required this.userId,
    required this.name,
    required this.bio,
    required this.avatarUrl,
    required this.selectedFandoms,
  });

  @override
  List<Object?> get props => [userId, name, bio, avatarUrl, selectedFandoms];
}

class LoadProfileOrdersEvent extends ProfileEvent {
  final String userId;
  const LoadProfileOrdersEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class ClearLocalCacheStorageEvent extends ProfileEvent {
  final String userId;
  const ClearLocalCacheStorageEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class UpdateAvatarEvent extends ProfileEvent {
  final String userId;
  final String imagePath;

  const UpdateAvatarEvent({required this.userId, required this.imagePath});

  @override
  List<Object?> get props => [userId, imagePath];
}

class UpdateProfileEvent extends ProfileEvent {
  final String userId;
  final String? bio;
  final String? city;
  final String? fanbase;

  const UpdateProfileEvent({
    required this.userId,
    this.bio,
    this.city,
    this.fanbase,
  });

  @override
  List<Object?> get props => [userId, bio, city, fanbase];
}
class ToggleLikeFandomEvent extends ProfileEvent {
  final String userId;
  final String categoryId;

  const ToggleLikeFandomEvent({required this.userId, required this.categoryId});

  @override
  List<Object?> get props => [userId, categoryId];
}

