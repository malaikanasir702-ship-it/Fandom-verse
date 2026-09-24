import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProfileEvent extends ProfileEvent {
  final String userId;
  const LoadUserProfileEvent({this.userId = 'fan-01'});

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
    this.userId = 'fan-01',
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
  const LoadProfileOrdersEvent({this.userId = 'fan-01'});

  @override
  List<Object?> get props => [userId];
}

class ClearLocalCacheStorageEvent extends ProfileEvent {
  const ClearLocalCacheStorageEvent();
}
