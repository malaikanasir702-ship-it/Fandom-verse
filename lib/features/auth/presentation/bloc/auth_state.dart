import '../../domain/entities/user_entity.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class FanAuthenticated extends AuthState {
  final UserEntity user;
  const FanAuthenticated(this.user);
}

class AdminAuthenticated extends AuthState {
  final UserEntity admin;
  const AdminAuthenticated(this.admin);
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthFailure extends AuthState {
  final String errorMessage;
  const AuthFailure(this.errorMessage);
}
