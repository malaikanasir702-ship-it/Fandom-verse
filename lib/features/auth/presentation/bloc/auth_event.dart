import '../../domain/entities/user_entity.dart';

abstract class AuthEvent {
  const AuthEvent();
}

class CheckAuthSessionEvent extends AuthEvent {
  const CheckAuthSessionEvent();
}

class FanLoginSubmittedEvent extends AuthEvent {
  final String email;
  final String password;
  const FanLoginSubmittedEvent({required this.email, required this.password});
}

class FanRegisterSubmittedEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const FanRegisterSubmittedEvent({
    required this.name,
    required this.email,
    required this.password,
  });
}

class AdminLoginSubmittedEvent extends AuthEvent {
  final String email;
  final String password;
  const AdminLoginSubmittedEvent({required this.email, required this.password});
}

class UpdateUserInterestsEvent extends AuthEvent {
  final List<String> selectedFandoms;
  const UpdateUserInterestsEvent(this.selectedFandoms);
}

class SelectStarterBadgeEvent extends AuthEvent {
  final String badgeTitle;
  const SelectStarterBadgeEvent(this.badgeTitle);
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}
