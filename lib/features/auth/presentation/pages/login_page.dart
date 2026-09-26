import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/firebase_auth_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isResettingPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _showForgotPasswordSheet() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resetEmailController = TextEditingController(text: _emailController.text.trim());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Reset Password', style: AppTextStyles.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Enter your registered email address and we\'ll send you password reset instructions.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: resetEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.sms),
                    hintText: 'Enter your registered email',
                  ),
                ),
                const SizedBox(height: 20),
                SkewedButton(
                  text: _isResettingPassword ? 'Sending...' : 'Send Reset Link',
                  height: 52,
                  fontSize: 14,
                  onPressed: _isResettingPassword ? null : () async {
                    final email = resetEmailController.text.trim();
                    if (email.isEmpty) return;
                    setModalState(() => _isResettingPassword = true);
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(ctx);
                    try {
                      await sl<FirebaseAuthService>().sendPasswordResetEmail(email);
                      navigator.pop();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Password reset link sent! Check your email inbox.'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    } finally {
                      setModalState(() => _isResettingPassword = false);
                    }
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAppleSignInUnavailable() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.apple, size: 24),
            SizedBox(width: 10),
            Text(
              'Apple Sign-In',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Apple Sign-In is available on iOS devices only. Please use Google Sign-In or Email & Password to continue on Android.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Got it',
              style: TextStyle(
                color: AppColors.darkSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGuestModeDialog() {    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Continue as Guest?'),
        content: const Text(
          'In Guest Mode, you can explore lore and view events, but bookmarks, wishlist, and cart features require a real account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushReplacementNamed('/fan-home');
            },
            child: const Text('Explore as Guest'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is FanAuthenticated) {
          if (state.user.selectedFandoms.isEmpty) {
            Navigator.of(context).pushReplacementNamed('/interest-setup');
          } else {
            Navigator.of(context).pushReplacementNamed('/fan-home');
          }
        } else if (state is AdminAuthenticated) {
          Navigator.of(context).pushReplacementNamed('/admin-dashboard');
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Back button only
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Iconsax.arrow_left, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text('Welcome back', style: AppTextStyles.bodyLarge),
                  Text('Sign In', style: AppTextStyles.displayMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to sync your bookmarked lore, event passes, and merchandise wishlist.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Email Field
                  const Text('Email Address', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Iconsax.sms, size: 20),
                      hintText: 'Enter your email address',
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Password Field
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Password', style: TextStyle(fontWeight: FontWeight.w600)),
                      GestureDetector(
                        onTap: _showForgotPasswordSheet,
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppColors.darkSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Iconsax.lock, size: 20),
                      hintText: '••••••••',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Sign In Button
                  SkewedButton(
                    text: 'Sign In',
                    height: 52,
                    fontSize: 14,
                    onPressed: isLoading ? null : () {
                      context.read<AuthBloc>().add(
                            FanLoginSubmittedEvent(
                              email: _emailController.text,
                              password: _passwordController.text,
                            ),
                          );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          'OR CONTINUE WITH',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Google Sign-In Button
                  GestureDetector(
                    onTap: isLoading
                        ? null
                        : () => context.read<AuthBloc>().add(const GoogleSignInEvent()),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(24, 24),
                            painter: _GoogleLogoPainter(),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Continue with Google',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: isDark ? Colors.white : const Color(0xFF3C4043),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Apple Sign-In Button
                  GestureDetector(
                    onTap: isLoading ? null : _showAppleSignInUnavailable,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1C1C1E) : Colors.black,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : Colors.black,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.apple, color: Colors.white, size: 22),
                          SizedBox(width: 10),
                          Text(
                            'Continue with Apple',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    onTap: _showGuestModeDialog,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.profile_circle, size: 20),
                        SizedBox(width: 6),
                        Text('Continue as Guest', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed('/register');
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: AppColors.darkSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Draws the real Google "G" logo using CustomPaint — matches the official SVG exactly
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Blue path — top right arc
    final blue = Paint()..color = const Color(0xFF4285F4);
    // Red path — bottom left arc
    final red = Paint()..color = const Color(0xFFEA4335);
    // Yellow path — bottom left
    final yellow = Paint()..color = const Color(0xFFFBBC05);
    // Green path — bottom right
    final green = Paint()..color = const Color(0xFF34A853);

    // Scale factor
    final sx = w / 24;
    final sy = h / 24;

    // Blue — right side G shape
    final bluePath = Path()
      ..moveTo(23.745 * sx, 12.285 * sy)
      ..cubicTo(23.745 * sx, 11.335 * sy, 23.663 * sx, 10.745 * sy, 23.49 * sx, 10.127 * sy)
      ..lineTo(12.255 * sx, 10.127 * sy)
      ..lineTo(12.255 * sx, 14.753 * sy)
      ..lineTo(18.96 * sx, 14.753 * sy)
      ..cubicTo(18.69 * sx, 16.288 * sy, 17.57 * sx, 18.09 * sy, 15.975 * sx, 18.9 * sy)
      ..lineTo(15.975 * sx, 21.83 * sy)
      ..lineTo(19.965 * sx, 21.83 * sy)
      ..cubicTo(22.358 * sx, 19.63 * sy, 23.745 * sx, 16.245 * sy, 23.745 * sx, 12.285 * sy)
      ..close();
    canvas.drawPath(bluePath, blue);

    // Green — bottom right
    final greenPath = Path()
      ..moveTo(12.255 * sx, 24 * sy)
      ..cubicTo(15.6 * sx, 24 * sy, 18.39 * sx, 22.91 * sy, 19.965 * sx, 21.83 * sy)
      ..lineTo(15.975 * sx, 18.9 * sy)
      ..cubicTo(15.03 * sx, 19.545 * sy, 13.77 * sx, 19.965 * sy, 12.255 * sx, 19.965 * sy)
      ..cubicTo(8.985 * sx, 19.965 * sy, 6.255 * sx, 17.745 * sy, 5.265 * sx, 14.79 * sy)
      ..lineTo(1.14 * sx, 14.79 * sy)
      ..lineTo(1.14 * sx, 17.82 * sy)
      ..cubicTo(3.63 * sx, 22.5 * sy, 7.635 * sx, 24 * sy, 12.255 * sx, 24 * sy)
      ..close();
    canvas.drawPath(greenPath, green);

    // Yellow — left arc
    final yellowPath = Path()
      ..moveTo(5.265 * sx, 14.79 * sy)
      ..cubicTo(5.01 * sx, 14.04 * sy, 4.875 * sx, 13.245 * sy, 4.875 * sx, 12 * sy)
      ..cubicTo(4.875 * sx, 10.755 * sy, 5.01 * sx, 9.96 * sy, 5.265 * sx, 9.21 * sy)
      ..lineTo(5.265 * sx, 6.18 * sy)
      ..lineTo(1.14 * sx, 6.18 * sy)
      ..cubicTo(0.3 * sx, 7.755 * sy, 0 * sx, 9.795 * sy, 0 * sx, 12 * sy)
      ..cubicTo(0 * sx, 14.205 * sy, 0.3 * sx, 16.245 * sy, 1.14 * sx, 17.82 * sy)
      ..lineTo(5.265 * sx, 14.79 * sy)
      ..close();
    canvas.drawPath(yellowPath, yellow);

    // Red — top left
    final redPath = Path()
      ..moveTo(12.255 * sx, 4.035 * sy)
      ..cubicTo(14.415 * sx, 4.035 * sy, 15.9 * sx, 4.92 * sy, 16.68 * sx, 5.64 * sy)
      ..lineTo(20.01 * sx, 2.37 * sy)
      ..cubicTo(18.0 * sx, 0.48 * sy, 15.345 * sx, 0 * sy, 12.255 * sx, 0 * sy)
      ..cubicTo(7.635 * sx, 0 * sy, 3.63 * sx, 1.5 * sy, 1.14 * sx, 6.18 * sy)
      ..lineTo(5.265 * sx, 9.21 * sy)
      ..cubicTo(6.255 * sx, 6.255 * sy, 8.985 * sx, 4.035 * sy, 12.255 * sx, 4.035 * sy)
      ..close();
    canvas.drawPath(redPath, red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}