import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class InterestSetupPage extends StatefulWidget {
  const InterestSetupPage({super.key});

  @override
  State<InterestSetupPage> createState() => _InterestSetupPageState();
}

class _InterestSetupPageState extends State<InterestSetupPage> {
  final Set<String> _selectedFandoms = {'Anime & Manga', 'Gaming & Esports'};

  final Map<String, IconData> _categoryIcons = {
    'Anime & Manga': Iconsax.video_play,
    'Gaming & Esports': Iconsax.game,
    'Sci-Fi & Fantasy': Iconsax.star_1,
    'Marvel & DC Comics': Iconsax.book_1,
    'K-Pop & Idol Culture': Iconsax.music,
    'Pop Culture & Movies': Iconsax.ticket_2,
  };

  final Map<String, Color> _categoryColors = {
    'Anime & Manga': AppColors.animeViolet,
    'Gaming & Esports': AppColors.gamingGreen,
    'Sci-Fi & Fantasy': AppColors.sciFiCyan,
    'Marvel & DC Comics': AppColors.marvelRed,
    'K-Pop & Idol Culture': AppColors.kpopPink,
    'Pop Culture & Movies': AppColors.comicsAmber,
  };

  void _toggleCategory(String cat) {
    setState(() {
      if (_selectedFandoms.contains(cat)) {
        if (_selectedFandoms.length > 1) {
          _selectedFandoms.remove(cat);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Select at least 2 fandoms to personalize your feed.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        _selectedFandoms.add(cat);
      }
    });
  }

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.darkPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'PREFERENCES • 1 OF 2',
                      style: AppTextStyles.badgeText.copyWith(color: AppColors.darkPrimary),
                    ),
                  ),
                  Text(
                    '${_selectedFandoms.length} Selected',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text('Choose Your Universes', style: AppTextStyles.displaySmall),
              const SizedBox(height: 6),
              Text(
                'Select your primary fandom passions to tailor trending carousels, convention radars, and merchandise drops.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),

              const SizedBox(height: 24),

              // Categories Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: AppConstants.defaultCategories.length,
                  itemBuilder: (context, index) {
                    final cat = AppConstants.defaultCategories[index];
                    final isSelected = _selectedFandoms.contains(cat);
                    final icon = _categoryIcons[cat] ?? Iconsax.star_1;
                    final color = _categoryColors[cat] ?? AppColors.darkSecondary;

                    return GlassContainer(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 20,
                      borderColor: isSelected ? color : null,
                      backgroundColor: isSelected ? color.withValues(alpha: 0.18) : null,
                      onTap: () => _toggleCategory(cat),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(icon, color: color, size: 24),
                              ),
                              if (isSelected)
                                Icon(Iconsax.tick_circle, color: color, size: 20),
                            ],
                          ),
                          Text(
                            cat,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              CustomButton(
                text: 'Proceed to Badge Selection',
                icon: Iconsax.arrow_right,
                onPressed: () {
                  context.read<AuthBloc>().add(
                        UpdateUserInterestsEvent(_selectedFandoms.toList()),
                      );
                  Navigator.of(context).pushReplacementNamed('/badge-setup');
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




