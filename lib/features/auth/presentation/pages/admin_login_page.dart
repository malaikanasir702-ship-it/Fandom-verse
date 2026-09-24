import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _emailController = TextEditingController(text: 'admin@fandomverse.com');
  final _passwordController = TextEditingController(text: 'admin123');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillPreConfiguredAdmin() {
    setState(() {
      _emailController.text = 'admin@fandomverse.com';
      _passwordController.text = 'admin123';
    });
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
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: const Color(0xFF07090E), // Extra dark terminal tone
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_rounded, size: 12, color: AppColors.error),
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
                      color: AppColors.darkPrimary.withValues(alpha: 0.15),
                      border: Border.all(color: AppColors.darkPrimary, width: 1.5),
                    ),
                    child: const Center(
                      child: Icon(Icons.terminal_rounded, color: AppColors.darkPrimary, size: 32),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Admin Command Console',
                    style: AppTextStyles.displaySmall.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Authentication restricted to authorized content curators, convention directors & store moderators.',
                    style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.45),
                  ),

                  const SizedBox(height: 24),

                  // Pre-configured Credentials Helper Notice Box
                  GlassContainer(
                    padding: const EdgeInsets.all(14),
                    borderColor: AppColors.darkSecondary.withValues(alpha: 0.3),
                    backgroundColor: AppColors.darkSecondary.withValues(alpha: 0.08),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.darkSecondary, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SRS Pre-configured Credentials:',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.darkSecondary),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'admin@fandomverse.com • admin123',
                                style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _fillPreConfiguredAdmin,
                          child: const Text('Autofill', style: TextStyle(color: AppColors.darkSecondary, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text('Admin Account ID', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      fillColor: const Color(0xFF131722),
                      prefixIcon: const Icon(Icons.badge_outlined, color: Colors.white54, size: 20),
                      hintText: 'admin@fandomverse.com',
                      hintStyle: const TextStyle(color: Colors.white30),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text('Security Passcode', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      fillColor: const Color(0xFF131722),
                      prefixIcon: const Icon(Icons.key_rounded, color: Colors.white54, size: 20),
                      hintText: '••••••••',
                      hintStyle: const TextStyle(color: Colors.white30),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.white54,
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

                  CustomButton(
                    text: 'Authenticate & Open Console',
                    icon: Icons.vpn_key_rounded,
                    backgroundColor: AppColors.darkPrimary,
                    isLoading: isLoading,
                    onPressed: () {
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
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white38, fontSize: 11),
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
