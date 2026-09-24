import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

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
              const SizedBox(height: 20),
              // Header Tag
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.darkPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.darkPrimary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'PORTAL GATEWAY',
                      style: AppTextStyles.badgeText.copyWith(color: AppColors.darkPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Text(
                'Choose Your Role',
                style: AppTextStyles.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Step into the Fandom Universe as a passionate Fan Explorer or enter the Command Admin Console.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),

              const SizedBox(height: 36),

              // Choice Card 1: Fan User
              Expanded(
                child: GlassContainer(
                  padding: const EdgeInsets.all(22),
                  borderColor: AppColors.darkSecondary.withValues(alpha: 0.3),
                  onTap: () {
                    Navigator.of(context).pushNamed('/onboarding');
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppColors.darkSecondary, AppColors.darkPrimary],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.darkSecondary.withValues(alpha: 0.4),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 28),
                          ),
                          const Icon(Icons.arrow_forward_rounded, color: AppColors.darkSecondary),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fan Universe Explorer',
                            style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Discover trending anime & gaming lore, find conventions on Map Radar, browse official merchandise & chat with the AI helper.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildChip('Lore Hub', AppColors.darkSecondary),
                              _buildChip('Event Radar', AppColors.darkPrimary),
                              _buildChip('Merch Store', AppColors.darkAccentGold),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Choice Card 2: Admin User
              Expanded(
                child: GlassContainer(
                  padding: const EdgeInsets.all(22),
                  borderColor: AppColors.darkPrimary.withValues(alpha: 0.3),
                  onTap: () {
                    Navigator.of(context).pushNamed('/admin-login');
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.darkSurfaceElevated,
                              border: Border.all(color: AppColors.darkPrimary, width: 1.5),
                            ),
                            child: const Icon(Icons.shield_rounded, color: AppColors.darkPrimary, size: 28),
                          ),
                          const Icon(Icons.arrow_forward_rounded, color: AppColors.darkPrimary),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Command Admin Console',
                            style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pre-configured console for organizers to moderate content, schedule conventions, update merchandise & manage user roles.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildChip('Content Moderation', AppColors.darkPrimary),
                              _buildChip('Event Engine', AppColors.info),
                              _buildChip('Catalog Control', AppColors.error),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
