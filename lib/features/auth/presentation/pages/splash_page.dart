import 'dart:async';
import 'package:flutter/material.dart';
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

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
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
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
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
      debugPrint('⏱️ [SplashPage] Safety timeout reached, resolving destination.');
      final current = authBloc.state;
      if (current is FanAuthenticated || current is AdminAuthenticated) {
        _handleAuthState(current);
      } else {
        await _navigateUnauthenticated();
      }
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
    // Always black background matching the FANDOM VERSE brand logo
    const bgColor = Colors.black;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) => _handleAuthState(state),
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
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
                          // ── FANDOM VERSE wordmark logo ──────────────────
                          Image.asset(
                            'assets/images/splash_logo.png',
                            width: 280,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) {
                              // Fallback: draw the logo in code if image missing
                              return _FandomVerseFallbackLogo();
                            },
                          ),

                          const SizedBox(height: 48),

                          // Animated loading pill
                          SizedBox(
                            width: 130,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: const LinearProgressIndicator(
                                minHeight: 3.5,
                                backgroundColor: Color(0xFF2E313D),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.comicRed),
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
                    color: AppColors.darkTextSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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



/// Fallback: renders the FANDOM VERSE logo purely in Flutter widgets.
/// Used when splash_logo.png is not yet placed in assets/images/.
class _FandomVerseFallbackLogo extends StatelessWidget {
  const _FandomVerseFallbackLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── "FANDOM" in red-bordered speech-bubble box ─────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.comicRed, width: 3),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(4),
            ),
          ),
          child: const Text(
            'FANDOM',
            style: TextStyle(
              color: Colors.white,
              fontSize: 52,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              height: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // ── "VERSE" spaced below ─────────────────────────────────
        const Text(
          'V E R S E',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 10,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
