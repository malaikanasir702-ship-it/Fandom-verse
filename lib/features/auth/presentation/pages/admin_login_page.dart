import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AdminAuthenticated) {
          Navigator.of(context).pushReplacementNamed('/admin/dashboard');
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.adminLightBackground,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Iconsax.arrow_left, color: AppColors.adminLightTextPrimary, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.lock, size: 12, color: AppColors.error),
                    SizedBox(width: 4),
                    Text(
                      'SECURE CONSOLE',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Terminal Shield Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.comicRed.withValues(alpha: 0.1),
                      border: Border.all(color: AppColors.comicRed.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: const Center(
                      child: Icon(Iconsax.code, color: AppColors.comicRed, size: 32),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Admin Command Console',
                    style: AppTextStyles.displaySmall.copyWith(
                      color: AppColors.adminLightTextPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Authentication restricted to authorized content curators, convention directors & store moderators.',
                    style: TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 13, height: 1.45),
                  ),

                  const SizedBox(height: 24),

                  // Security notice
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.adminLightBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Iconsax.shield_tick, color: Color(0xFF2563EB), size: 22),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Admin access is role-restricted. Your account must have administrator privileges to proceed.',
                            style: TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 12, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Admin Account ID',
                    style: TextStyle(color: AppColors.adminLightTextPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 14),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      prefixIcon: const Icon(Iconsax.card, color: AppColors.adminLightTextSecondary, size: 20),
                      hintText: 'Enter admin email address',
                      hintStyle: const TextStyle(color: AppColors.adminLightTextMuted, fontSize: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.adminLightBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.adminLightBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.comicRed, width: 1.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Security Passcode',
                    style: TextStyle(color: AppColors.adminLightTextPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      prefixIcon: const Icon(Iconsax.key, color: AppColors.adminLightTextSecondary, size: 20),
                      hintText: '••••••••',
                      hintStyle: const TextStyle(color: AppColors.adminLightTextMuted, fontSize: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.adminLightBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.adminLightBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.comicRed, width: 1.5),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                          color: AppColors.adminLightTextSecondary,
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

                  const SizedBox(height: 32),

                  SkewedButton(
                    text: isLoading ? 'Authenticating...' : 'Authenticate & Open Console',
                    icon: Iconsax.key_square,
                    height: 52,
                    fontSize: 13,
                    backgroundColor: AppColors.comicRed,
                    textColor: Colors.white,
                    onPressed: isLoading ? null : () {
                      context.read<AuthBloc>().add(
                            AdminLoginSubmittedEvent(
                              email: _emailController.text,
                              password: _passwordController.text,
                            ),
                          );
                    },
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: Text(
                      'All console actions are audited and logged with timestamps.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.adminLightTextMuted, fontSize: 11),
                    ),
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
