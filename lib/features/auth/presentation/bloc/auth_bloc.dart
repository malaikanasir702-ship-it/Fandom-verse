import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/firebase_auth_service.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuthService _authService;
  UserEntity? _currentUser;

  AuthBloc({FirebaseAuthService? authService})
      : _authService = authService ?? sl<FirebaseAuthService>(),
        super(const AuthInitial()) {
    on<CheckAuthSessionEvent>(_onCheckAuthSession);
    on<FanLoginSubmittedEvent>(_onFanLoginSubmitted);
    on<FanRegisterSubmittedEvent>(_onFanRegisterSubmitted);
    on<AdminLoginSubmittedEvent>(_onAdminLoginSubmitted);
    on<UpdateUserInterestsEvent>(_onUpdateUserInterests);
    on<SelectStarterBadgeEvent>(_onSelectStarterBadge);
    on<UpdateUserProfileEvent>(_onUpdateUserProfile);
    on<LogoutEvent>(_onLogout);
  }

  UserEntity? get currentUser => _currentUser;

  /// Check if there's an existing auth session on app start
  Future<void> _onCheckAuthSession(
    CheckAuthSessionEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        final profile = await _authService.getUserProfile(
          firebaseUser.uid,
          email: firebaseUser.email,
        );
        if (profile != null) {
          _currentUser = UserEntity.fromMap(profile);
          if (_currentUser!.status != 'active') {
            await _authService.signOut();
            _currentUser = null;
            emit(const AuthFailure('Your account has been suspended.'));
            return;
          }
          if (_currentUser!.isAdmin) {
            emit(AdminAuthenticated(_currentUser!));
          } else {
            emit(FanAuthenticated(_currentUser!));
          }
          return;
        }
      }
    } catch (e) {
      debugPrint('[AuthBloc] Session check error: $e');
    }
    emit(const Unauthenticated());
  }

  /// Handle fan/user login
  Future<void> _onFanLoginSubmitted(
    FanLoginSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final email = event.email.trim().toLowerCase();
    final password = event.password.trim();

    if (email.isEmpty || password.isEmpty) {
      emit(const AuthFailure('Please provide both email and password.'));
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      emit(const AuthFailure('Please enter a valid email address.'));
      return;
    }

    try {
      final userData = await _authService.signIn(
        email: email,
        password: password,
      );

      _currentUser = UserEntity.fromMap(userData);

      // Authorization check — suspended accounts cannot log in
      if (_currentUser!.status != 'active') {
        await _authService.signOut();
        _currentUser = null;
        emit(const AuthFailure('Your account has been suspended by an administrator.'));
        return;
      }

      if (_currentUser!.isAdmin) {
        emit(AdminAuthenticated(_currentUser!));
      } else {
        emit(FanAuthenticated(_currentUser!));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_mapFirebaseError(e)));
    } on FormatException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      debugPrint('[AuthBloc] Login error: $e');
      emit(AuthFailure('Sign-in failed: ${e.toString()}'));
    }
  }

  /// Handle new fan registration
  Future<void> _onFanRegisterSubmitted(
    FanRegisterSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final name = event.name.trim();
    final email = event.email.trim().toLowerCase();
    final password = event.password.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      emit(const AuthFailure('Name, email, and password are all required.'));
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      emit(const AuthFailure('Please enter a valid email address.'));
      return;
    }

    if (password.length < 6) {
      emit(const AuthFailure('Password must be at least 6 characters long.'));
      return;
    }

    try {
      final userData = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        role: 'fan',
        selectedFandoms: [],
      );

      _currentUser = UserEntity.fromMap(userData);
      emit(FanAuthenticated(_currentUser!));
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_mapFirebaseError(e)));
    } on FormatException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      debugPrint('[AuthBloc] Register error: $e');
      emit(AuthFailure('Registration failed: ${e.toString()}'));
    }
  }

  /// Handle admin login — requires the account to have role=admin in the database
  Future<void> _onAdminLoginSubmitted(
    AdminLoginSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final email = event.email.trim().toLowerCase();
    final password = event.password.trim();

    if (email.isEmpty || password.isEmpty) {
      emit(const AuthFailure('Admin email and password are required.'));
      return;
    }

    try {
      final userData = await _authService.signIn(
        email: email,
        password: password,
      );

      _currentUser = UserEntity.fromMap(userData);

      // Authorization: only accounts with role=admin can access the admin console
      if (!_currentUser!.isAdmin) {
        await _authService.signOut();
        _currentUser = null;
        emit(const AuthFailure(
          'Access Denied. This account does not have administrator privileges.',
        ));
        return;
      }

      if (_currentUser!.status != 'active') {
        await _authService.signOut();
        _currentUser = null;
        emit(const AuthFailure('Your admin account has been suspended.'));
        return;
      }

      emit(AdminAuthenticated(_currentUser!));
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_mapFirebaseError(e)));
    } on FormatException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      debugPrint('[AuthBloc] Admin login error: $e');
      emit(const AuthFailure('Admin authentication failed. Please try again.'));
    }
  }

  void _onUpdateUserInterests(
    UpdateUserInterestsEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(selectedFandoms: event.selectedFandoms);

      // Persist to Firebase / SQLite
      await _authService.updateUserInterests(_currentUser!.id, event.selectedFandoms);
      emit(FanAuthenticated(_currentUser!));
    }
  }

  void _onSelectStarterBadge(
    SelectStarterBadgeEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (_currentUser != null) {
      final updatedBadges = List<String>.from(_currentUser!.badges);
      if (!updatedBadges.contains(event.badgeTitle)) {
        updatedBadges.add(event.badgeTitle);
      }
      _currentUser = _currentUser!.copyWith(badges: updatedBadges);

      // Persist badge to Firebase
      await _authService.addBadge(_currentUser!.id, event.badgeTitle);
      emit(FanAuthenticated(_currentUser!));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    UserEntity user = _currentUser ?? const UserEntity(
      id: 'fan-01',
      name: 'Alex Rivera',
      email: 'fan@fandomverse.com',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400',
      bio: 'Die-hard Shonen anime fan, Soulsborne speedrun enthusiast, and Marvel comics archivist.',
      selectedFandoms: ['Anime & Manga', 'Gaming & Esports'],
    );

    final updatedAvatar = event.removeAvatar ? null : (event.avatarUrl ?? user.avatarUrl);
    final updatedName = (event.name != null && event.name!.trim().isNotEmpty)
        ? event.name!.trim()
        : user.name;
    final updatedBio = event.bio ?? user.bio;

    user = user.copyWith(
      name: updatedName,
      bio: updatedBio,
      avatarUrl: updatedAvatar,
      clearAvatar: event.removeAvatar,
    );
    _currentUser = user;

    await _authService.updateUserProfile(
      uid: user.id,
      name: updatedName,
      bio: updatedBio,
      avatarUrl: updatedAvatar,
      removeAvatar: event.removeAvatar,
    );

    if (user.isAdmin) {
      emit(AdminAuthenticated(user));
    } else {
      emit(FanAuthenticated(user));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      await _authService.signOut();
    } catch (e) {
      debugPrint('[AuthBloc] Logout error: $e');
    }
    _currentUser = null;
    emit(const Unauthenticated());
  }

  /// Map Firebase error codes to user-friendly messages
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'invalid-credential':
        return 'No account found with these credentials. Please check your email and password.';
      case 'wrong-password':
        return 'Incorrect password. Please try again or use Forgot Password.';
      case 'email-already-in-use':
        return 'An account with this email address already exists. Try logging in instead.';
      case 'invalid-email':
        return 'The email address is not valid. Please check and try again.';
      case 'user-disabled':
        return 'Your account has been disabled. Please contact support.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters with numbers and letters.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait a moment before trying again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      default:
        debugPrint('[AuthBloc] Unhandled Firebase error: ${e.code} - ${e.message}');
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
