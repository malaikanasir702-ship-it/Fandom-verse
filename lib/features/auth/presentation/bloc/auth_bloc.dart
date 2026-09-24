import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Pre-configured test accounts as per SRS Section 1.9 & Requirements
  static const UserEntity defaultAdmin = UserEntity(
    id: 'admin-01',
    name: 'Fandom Commander',
    email: 'admin@fandomverse.com',
    role: 'admin',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
    bio: 'Lead Operations Administrator & Curator',
    badges: ['Admin Commander', 'System Architect'],
    selectedFandoms: ['All'],
  );

  static const UserEntity defaultFan = UserEntity(
    id: 'fan-01',
    name: 'Alex Mercer',
    email: 'fan@fandomverse.com',
    role: 'fan',
    avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400',
    bio: 'Avid anime watcher, lore analyst & speedrunner.',
    badges: ['Master Lorekeeper', 'Con Veteran 2025'],
    selectedFandoms: ['Anime & Manga', 'Gaming & Esports'],
  );

  UserEntity? _currentUser;

  AuthBloc() : super(const AuthInitial()) {
    on<CheckAuthSessionEvent>(_onCheckAuthSession);
    on<FanLoginSubmittedEvent>(_onFanLoginSubmitted);
    on<FanRegisterSubmittedEvent>(_onFanRegisterSubmitted);
    on<AdminLoginSubmittedEvent>(_onAdminLoginSubmitted);
    on<UpdateUserInterestsEvent>(_onUpdateUserInterests);
    on<SelectStarterBadgeEvent>(_onSelectStarterBadge);
    on<LogoutEvent>(_onLogout);
  }

  UserEntity? get currentUser => _currentUser;

  void _onCheckAuthSession(
    CheckAuthSessionEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(const Unauthenticated());
  }

  void _onFanLoginSubmitted(
    FanLoginSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 600));

    final email = event.email.trim().toLowerCase();
    final pass = event.password.trim();

    if (email.isEmpty || pass.isEmpty) {
      emit(const AuthFailure('Please provide both email and password.'));
      return;
    }

    if (email == 'fan@fandomverse.com' && pass == 'fan123') {
      _currentUser = defaultFan;
      emit(FanAuthenticated(_currentUser!));
    } else if (email.contains('@')) {
      // Allow dynamic fan login with user-provided credentials
      _currentUser = UserEntity(
        id: 'fan-${DateTime.now().millisecondsSinceEpoch}',
        name: email.split('@').first,
        email: email,
        role: 'fan',
        badges: ['Novice Otaku'],
        selectedFandoms: ['Anime & Manga'],
      );
      emit(FanAuthenticated(_currentUser!));
    } else {
      emit(const AuthFailure('Invalid credentials. Use fan@fandomverse.com / fan123'));
    }
  }

  void _onFanRegisterSubmitted(
    FanRegisterSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 700));

    if (event.name.trim().isEmpty || event.email.trim().isEmpty || event.password.trim().isEmpty) {
      emit(const AuthFailure('All fields are required.'));
      return;
    }

    _currentUser = UserEntity(
      id: 'fan-${DateTime.now().millisecondsSinceEpoch}',
      name: event.name.trim(),
      email: event.email.trim().toLowerCase(),
      role: 'fan',
      badges: ['Novice Otaku'],
      selectedFandoms: ['Anime & Manga'],
    );
    emit(FanAuthenticated(_currentUser!));
  }

  void _onAdminLoginSubmitted(
    AdminLoginSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 600));

    final email = event.email.trim().toLowerCase();
    final pass = event.password.trim();

    if (email == 'admin@fandomverse.com' && pass == 'admin123') {
      _currentUser = defaultAdmin;
      emit(AdminAuthenticated(_currentUser!));
    } else {
      emit(const AuthFailure('Access Denied. Use admin@fandomverse.com / admin123'));
    }
  }

  void _onUpdateUserInterests(
    UpdateUserInterestsEvent event,
    Emitter<AuthState> emit,
  ) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(selectedFandoms: event.selectedFandoms);
      emit(FanAuthenticated(_currentUser!));
    }
  }

  void _onSelectStarterBadge(
    SelectStarterBadgeEvent event,
    Emitter<AuthState> emit,
  ) {
    if (_currentUser != null) {
      final updatedBadges = List<String>.from(_currentUser!.badges);
      if (!updatedBadges.contains(event.badgeTitle)) {
        updatedBadges.add(event.badgeTitle);
      }
      _currentUser = _currentUser!.copyWith(badges: updatedBadges);
      emit(FanAuthenticated(_currentUser!));
    }
  }

  void _onLogout(LogoutEvent event, Emitter<AuthState> emit) {
    _currentUser = null;
    emit(const Unauthenticated());
  }
}
