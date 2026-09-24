import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glowing_badge.dart';

class BadgesAchievementsPage extends StatelessWidget {
  const BadgesAchievementsPage({super.key});

  static final List<Map<String, dynamic>> _badges = [
    {
      'name': 'Lorekeeper Master',
      'desc': 'Bookmarked and mastered over 50 glossary terms across 3 fandoms.',
      'icon': Iconsax.book_1,
      'unlocked': true,
      'tier': 'Gold Tier',
      'date': 'Unlocked Oct 2024',
    },
    {
      'name': 'Con Navigator',
      'desc': 'RSVP\'d and checked in at 3 real-world conventions or comic cons.',
      'icon': Iconsax.ticket,
      'unlocked': true,
      'tier': 'Silver Tier',
      'date': 'Unlocked Nov 2024',
    },
    {
      'name': 'Discussion Pioneer',
      'desc': 'Created a thread with over 100 community upvotes and 50 replies.',
      'icon': Iconsax.messages_1,
      'unlocked': true,
      'tier': 'Platinum Tier',
      'date': 'Unlocked Dec 2024',
    },
    {
      'name': 'Trivia Archmage',
      'desc': 'Answer 20 consecutive deep-dive trivia questions without a single mistake.',
      'icon': Iconsax.flash_1,
      'unlocked': false,
      'tier': 'Diamond Tier',
      'date': 'Progress: 14 / 20',
    },
    {
      'name': 'Multiverse Explorer',
      'desc': 'Follow at least 1 creator or actor from 5 distinct fandom categories.',
      'icon': Iconsax.global,
      'unlocked': false,
      'tier': 'Gold Tier',
      'date': 'Progress: 3 / 5',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Achievements & Badges', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // XP Progression Hero
          GlassContainer(
            padding: const EdgeInsets.all(20),
            borderColor: AppColors.comicYellow.withValues(alpha: 0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Level 18 Fan Explorer',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '3,420 / 4,000 XP to Level 19',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    const GlowingBadge(
                      label: 'Tier III',
                      color: AppColors.comicYellow,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: 0.85,
                    minHeight: 10,
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    color: AppColors.comicYellow,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Iconsax.lamp_on, size: 14, color: AppColors.comicYellow),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Next unlock: Custom Solid Avatar Border & Verified Lore Badge',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white70 : AppColors.lightTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              const Icon(Iconsax.medal_star, size: 20, color: AppColors.comicRed),
              const SizedBox(width: 8),
              Text(
                'All Trophies & Badges',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),

          ..._badges.map((b) {
            final unlocked = b['unlocked'] as bool;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                borderColor: unlocked ? AppColors.comicYellow.withValues(alpha: 0.5) : null,
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: unlocked
                            ? AppColors.comicYellow.withValues(alpha: 0.15)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Icon(
                          b['icon'] as IconData,
                          size: 24,
                          color: unlocked ? AppColors.comicYellow : Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                b['name'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: unlocked ? null : Colors.grey,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: unlocked
                                      ? AppColors.comicYellow.withValues(alpha: 0.15)
                                      : Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  b['tier'] as String,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: unlocked ? AppColors.comicYellow : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            b['desc'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            b['date'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: unlocked ? AppColors.success : AppColors.comicRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
