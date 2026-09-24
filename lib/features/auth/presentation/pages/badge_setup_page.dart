import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class BadgeSetupPage extends StatefulWidget {
  const BadgeSetupPage({super.key});

  @override
  State<BadgeSetupPage> createState() => _BadgeSetupPageState();
}

class _BadgeSetupPageState extends State<BadgeSetupPage> {
  String _selectedBadge = 'Lorekeeper';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.darkAccentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'PREFERENCES • 2 OF 2',
                  style: AppTextStyles.badgeText.copyWith(color: AppColors.darkAccentGold),
                ),
              ),
              const SizedBox(height: 16),

              Text('Claim Your Starter Badge', style: AppTextStyles.displaySmall),
              const SizedBox(height: 6),
              Text(
                'Your starter badge showcases your fandom specialization on your public profile and community discussions.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),

              const SizedBox(height: 24),

              // Badges List
              Expanded(
                child: ListView.builder(
                  itemCount: AppConstants.starterBadges.length,
                  itemBuilder: (context, index) {
                    final item = AppConstants.starterBadges[index];
                    final title = item['title']!;
                    final desc = item['desc']!;
                    final icon = item['icon']!;
                    final isSelected = _selectedBadge == title;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(18),
                        borderRadius: 18,
                        borderColor: isSelected ? AppColors.darkAccentGold : null,
                        backgroundColor: isSelected
                            ? AppColors.darkAccentGold.withValues(alpha: 0.14)
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedBadge = title;
                          });
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                                border: Border.all(
                                  color: isSelected ? AppColors.darkAccentGold : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(icon, style: const TextStyle(fontSize: 24)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: AppTextStyles.titleMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: isSelected ? AppColors.darkAccentGold : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    desc,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                              color: isSelected ? AppColors.darkAccentGold : (isDark ? Colors.white24 : Colors.black26),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              CustomButton(
                text: 'Enter Fandom Universe',
                icon: Icons.auto_awesome_rounded,
                onPressed: () {
                  context.read<AuthBloc>().add(SelectStarterBadgeEvent(_selectedBadge));
                  Navigator.of(context).pushReplacementNamed('/fan-home');
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
