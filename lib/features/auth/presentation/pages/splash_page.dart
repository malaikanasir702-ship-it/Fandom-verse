import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  Timer? _fallbackTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Fire auth session check
    final authBloc = context.read<AuthBloc>();
    authBloc.add(const CheckAuthSessionEvent());

    // Safety fallback timer: guarantees splash NEVER gets stuck on slow or offline devices
    _fallbackTimer = Timer(const Duration(milliseconds: 2400), () async {
      if (_hasNavigated || !mounted) return;
      debugPrint('⏱️ [SplashPage] Safety timeout reached, navigating to fallback route.');
      await _navigateUnauthenticated();
    });

    // Check if state is already resolved
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_hasNavigated || !mounted) return;
      final currentState = authBloc.state;
      if (currentState is FanAuthenticated || currentState is AdminAuthenticated) {
        _handleAuthState(currentState);
      }
    });
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _safeNavigate(String route) {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _fallbackTimer?.cancel();
    Navigator.of(context).pushReplacementNamed(route);
  }

  Future<void> _navigateUnauthenticated() async {
    if (_hasNavigated || !mounted) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool('onboarding_seen') ?? false;
      _safeNavigate(seen ? '/login' : '/onboarding');
    } catch (_) {
      _safeNavigate('/onboarding');
    }
  }

  void _handleAuthState(AuthState state) {
    if (_hasNavigated || !mounted) return;

    if (state is FanAuthenticated) {
      if (state.user.selectedFandoms.isEmpty) {
        _safeNavigate('/interest-setup');
      } else {
        _safeNavigate('/fan-home');
      }
    } else if (state is AdminAuthenticated) {
      _safeNavigate('/admin-dashboard');
    } else if (state is Unauthenticated || state is AuthFailure) {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (!mounted || _hasNavigated) return;
        _navigateUnauthenticated();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) => _handleAuthState(state),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A1A),
        body: Stack(
          children: [
            // Background ambient gradient
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2),

                radius: 1.2,
                colors: isDark
                    ? [
                        AppColors.darkPrimary.withValues(alpha: 0.25),
                        AppColors.darkBackground,
                      ]
                    : [
                        AppColors.lightPrimary.withValues(alpha: 0.15),
                        AppColors.lightBackground,
                      ],
              ),
            ),
          ),

          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Universe Portal Icon
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.darkPrimary,
                                AppColors.darkSecondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.darkSecondary.withValues(alpha: 0.5),
                                blurRadius: 28,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Iconsax.star_1,
                              size: 54,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Title
                        Text(
                          AppConstants.appName,
                          style: AppTextStyles.displayMedium.copyWith(
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          AppConstants.appSubtitle,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Animated loading pill
                        SizedBox(
                          width: 140,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              minHeight: 3,
                              backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.darkSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom version tag
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'v${AppConstants.appVersion} • Fandom Verse Pocket Edition',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}


