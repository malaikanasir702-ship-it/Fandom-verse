import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillDemoFanCredentials() {
    setState(() {
      _emailController.text = 'fan@fandomverse.com';
      _passwordController.text = 'fan123';
    });
  }

  void _fillDemoAdminCredentials() {
    setState(() {
      _emailController.text = 'admin@fandomverse.com';
      _passwordController.text = 'admin123';
    });
  }

  void _showForgotPasswordSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resetEmailController = TextEditingController(text: _emailController.text);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
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
                'Enter your registered email address to receive password reset instructions.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: resetEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined),
                  hintText: 'Enter your email',
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Send Reset Instructions',
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset link sent to your email.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _showGuestModeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Continue as Guest?'),
        content: const Text(
          'In Guest Mode, you can explore lore and view events, but offline bookmarks and simulated wishlist cart require an account.',
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
                  // Top Row with Back and Quick Demo buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                      ),
                      Row(
                        children: [
                          ActionChip(
                            avatar: const Icon(Icons.flash_on_rounded, size: 14, color: AppColors.darkSecondary),
                            label: const Text('Fan Demo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                            onPressed: _fillDemoFanCredentials,
                          ),
                          const SizedBox(width: 6),
                          ActionChip(
                            avatar: const Icon(Icons.shield_rounded, size: 14, color: AppColors.darkAccentGold),
                            label: const Text('Admin Demo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.darkAccentGold)),
                            onPressed: _fillDemoAdminCredentials,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text('Welcome to', style: AppTextStyles.bodyLarge),
                  Text('Fandom Verse', style: AppTextStyles.displayMedium),
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
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
                      hintText: 'e.g. fan@fandomverse.com',
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
                          'Forgot?',
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
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                      hintText: '••••••••',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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

                  // Submit Button
                  CustomButton(
                    text: 'Sign In',
                    isLoading: isLoading,
                    onPressed: () {
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
                          'OR EXPLORE WITH',
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

                  // Social / Guest Buttons
                  Row(
                    children: [
                      Expanded(
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          onTap: () {
                            _emailController.text = 'google.fan@fandomverse.com';
                            _passwordController.text = 'fan123';
                            context.read<AuthBloc>().add(
                                  FanLoginSubmittedEvent(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  ),
                                );
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.g_mobiledata_rounded, size: 28),
                              SizedBox(width: 4),
                              Text('Google', style: TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          onTap: _showGuestModeDialog,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_outline_rounded, size: 20),
                              SizedBox(width: 6),
                              Text('Guest Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
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
