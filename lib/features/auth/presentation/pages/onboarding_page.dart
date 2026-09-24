import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'Unified Fandom Universe',
      'subtitle':
          'No more scattered wikis or fragmented forums. Access anime lore, gaming records, superhero timelines, and glossary lexicons in one unified hub.',
      'icon': Icons.hub_rounded,
      'color': AppColors.darkPrimary,
    },
    {
      'title': 'Location-Aware Event Radar',
      'subtitle':
          'Discover nearby Comic-Cons, cosplay gatherings, and movie screenings using interactive GPS maps, city filters, and instant ticket links.',
      'icon': Icons.radar_rounded,
      'color': AppColors.darkSecondary,
    },
    {
      'title': 'Official Merchandise & AI Helper',
      'subtitle':
          'Track authentic merchandise with wishlist drop alerts, simulated checkout invoices, and an AI Fan Assistant ready to answer deep universe lore.',
      'icon': Icons.shopping_bag_rounded,
      'color': AppColors.darkAccentGold,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Top Bar with Skip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'STEP ${_currentIndex + 1} OF 3',
                    style: AppTextStyles.badgeText.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    final Color slideColor = slide['color'] as Color;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon Orb
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: slideColor.withValues(alpha: 0.12),
                            border: Border.all(color: slideColor.withValues(alpha: 0.35), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: slideColor.withValues(alpha: 0.3),
                                blurRadius: 28,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              slide['icon'] as IconData,
                              size: 64,
                              color: slideColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Title
                        Text(
                          slide['title'] as String,
                          style: AppTextStyles.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Subtitle
                        Text(
                          slide['subtitle'] as String,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            height: 1.55,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Indicators & Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? AppColors.darkSecondary
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Bottom Button
              CustomButton(
                text: _currentIndex == _slides.length - 1 ? 'Enter Fandom Verse' : 'Continue',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  if (_currentIndex < _slides.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
