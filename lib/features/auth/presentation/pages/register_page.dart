import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreeTerms = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  double _calculatePasswordStrength(String pass) {
    if (pass.isEmpty) return 0.0;
    double score = 0.2;
    if (pass.length >= 6) score += 0.3;
    if (pass.contains(RegExp(r'[A-Z]'))) score += 0.25;
    if (pass.contains(RegExp(r'[0-9]'))) score += 0.25;
    return score.clamp(0.0, 1.0);
  }

  Color _getStrengthColor(double strength) {
    if (strength <= 0.3) return AppColors.error;
    if (strength <= 0.7) return AppColors.warning;
    return AppColors.success;
  }

  String _getStrengthText(double strength) {
    if (strength <= 0.3) return 'Weak';
    if (strength <= 0.7) return 'Medium';
    return 'Strong';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is FanAuthenticated) {
          Navigator.of(context).pushReplacementNamed('/interest-setup');
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
        final passStrength = _calculatePasswordStrength(_passwordController.text);

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text('Create Account'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Join the Fandom',
                    style: AppTextStyles.displaySmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Set up your fan identity to unlock personalized lore, community discussions, and offline badges.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Full Name
                  const Text('Fan Name / Alias', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                      hintText: 'e.g. Kenji Otaku',
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Email
                  const Text('Email Address', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
                      hintText: 'yourname@domain.com',
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Password
                  const Text('Password', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                      hintText: 'Minimum 6 characters',
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

                  if (_passwordController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: passStrength,
                              minHeight: 5,
                              backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              valueColor: AlwaysStoppedAnimation<Color>(_getStrengthColor(passStrength)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _getStrengthText(passStrength),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStrengthColor(passStrength),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 18),

                  // Confirm Password
                  const Text('Confirm Password', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscurePassword,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.lock_reset_rounded, size: 20),
                      hintText: 'Re-enter password',
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Terms checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeTerms,
                        activeColor: AppColors.darkPrimary,
                        onChanged: (val) {
                          setState(() {
                            _agreeTerms = val ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          'I agree to the Fandom Verse Community Guidelines & Terms.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  CustomButton(
                    text: 'Continue to Fandom Selection',
                    isLoading: isLoading,
                    onPressed: () {
                      if (!_agreeTerms) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please accept the guidelines to proceed.'),
                            backgroundColor: AppColors.warning,
                          ),
                        );
                        return;
                      }

                      if (_passwordController.text != _confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Passwords do not match.'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      context.read<AuthBloc>().add(
                            FanRegisterSubmittedEvent(
                              name: _nameController.text,
                              email: _emailController.text,
                              password: _passwordController.text,
                            ),
                          );
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
