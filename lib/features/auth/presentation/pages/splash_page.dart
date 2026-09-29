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
      if (current is FanAuthenticated || current is AdminAuthenticated || current is AuthSuspended) {
        _handleAuthState(current);
      } else {
        await _navigateUnauthenticated();
      }
    });

    // Check if state is already resolved
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_hasNavigated || !mounted) return;
      final currentState = authBloc.state;
      if (currentState is FanAuthenticated || currentState is AdminAuthenticated || currentState is AuthSuspended) {
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
    } else if (state is AuthSuspended) {
      if (_hasNavigated || !mounted) return;
      _hasNavigated = true;
      _fallbackTimer?.cancel();
      Navigator.of(context).pushReplacementNamed('/account-suspended', arguments: state.user);
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
                          // ── FANDOM VERSE splash logo ────────────────────
                          // Force load with no fallback — splash_logo.png must show
                          Image(
                            image: const AssetImage('assets/images/splash_logo.png'),
                            width: 280,
                            fit: BoxFit.contain,
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



/// Fallback: renders the exact FANDOM VERSE logo in Flutter widgets.
/// Matches the splash_logo.png — black bg, red speech-bubble box for FANDOM, white VERSE below.
class _FandomVerseFallbackLogo extends StatelessWidget {
  const _FandomVerseFallbackLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Red speech-bubble with "FANDOM" ──────────────────────
          CustomPaint(
            painter: _SpeechBubblePainter(),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              child: const Text(
                'FANDOM',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  height: 1.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // ── "VERSE" below ────────────────────────────────────────
          const Text(
            'V E R S E',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: 12,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeechBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFE51924); // Fandom red
    const r = 8.0; // corner radius
    const tail = 14.0; // tail width
    const tailH = 12.0; // tail height

    final path = Path()
      // top-left corner
      ..moveTo(r, 0)
      ..lineTo(size.width - r, 0)
      // top-right
      ..arcToPoint(Offset(size.width, r), radius: const Radius.circular(r))
      ..lineTo(size.width, size.height - r)
      // bottom-right
      ..arcToPoint(Offset(size.width - r, size.height),
          radius: const Radius.circular(r))
      // bottom — tail on left side (like speech bubble pointing bottom-left)
      ..lineTo(tail + r, size.height)
      ..lineTo(0, size.height + tailH)
      ..lineTo(0, size.height)
      ..lineTo(r, size.height)
      ..arcToPoint(Offset(0, size.height - r),
          radius: const Radius.circular(r), clockwise: false)
      ..lineTo(0, r)
      // top-left
      ..arcToPoint(Offset(r, 0), radius: const Radius.circular(r))
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
