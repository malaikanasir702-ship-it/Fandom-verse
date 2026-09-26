import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glowing_badge.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';

class BadgesAchievementsPage extends StatelessWidget {
  const BadgesAchievementsPage({super.key});

  // All possible badges — unlocked status determined dynamically
  static const List<Map<String, dynamic>> _allBadges = [
    {
      'id': 'novice_otaku',
      'name': 'Novice Otaku',
      'desc': 'Welcome to Fandom Verse! You joined the community.',
      'icon': Iconsax.star_1,
      'tier': 'Bronze Tier',
      'requiredBadgeName': 'Novice Otaku',
    },
    {
      'id': 'lorekeeper',
      'name': 'Lorekeeper Master',
      'desc': 'Bookmarked and mastered over 50 glossary terms across 3 fandoms.',
      'icon': Iconsax.book_1,
      'tier': 'Gold Tier',
      'requiredBadgeName': 'Master Lorekeeper',
    },
    {
      'id': 'con_navigator',
      'name': 'Con Navigator',
      'desc': 'RSVP\'d and checked in at 3 real-world conventions.',
      'icon': Iconsax.ticket,
      'tier': 'Silver Tier',
      'requiredBadgeName': 'Con Veteran 2025',
    },
    {
      'id': 'discussion_pioneer',
      'name': 'Discussion Pioneer',
      'desc': 'Created a thread with over 100 upvotes and 50 replies.',
      'icon': Iconsax.messages_1,
      'tier': 'Platinum Tier',
      'requiredBadgeName': 'Discussion Pioneer',
    },
    {
      'id': 'speedrun_guru',
      'name': 'Speedrun Guru',
      'desc': 'Completed the entire lore hub in under 30 minutes.',
      'icon': Iconsax.flash_1,
      'tier': 'Diamond Tier',
      'requiredBadgeName': 'Speedrun Guru',
    },
    {
      'id': 'multiverse_explorer',
      'name': 'Multiverse Explorer',
      'desc': 'Followed content from 5 distinct fandom categories.',
      'icon': Iconsax.global,
      'tier': 'Gold Tier',
      'requiredBadgeName': 'Multiverse Explorer',
    },
    {
      'id': 'admin_commander',
      'name': 'Admin Commander',
      'desc': 'System administrator with full platform access.',
      'icon': Iconsax.security_user,
      'tier': 'Admin Tier',
      'requiredBadgeName': 'Admin Commander',
    },
    {
      'id': 'system_architect',
      'name': 'System Architect',
      'desc': 'Core system architect behind Fandom Verse.',
      'icon': Iconsax.code_1,
      'tier': 'Admin Tier',
      'requiredBadgeName': 'System Architect',
    },
  ];

  List<String> _parseUserBadges(dynamic raw) {
    if (raw == null) return [];
    final str = raw.toString();
    return str
        .replaceAll('[', '')
        .replaceAll(']', '')
        .split(',')
        .map((b) => b.trim())
        .where((b) => b.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authUser = context.watch<AuthBloc>().currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Achievements & Badges',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, profileState) {
          // Get real badges from AuthBloc (live user) or ProfileBloc (DB user)
          List<String> userBadges = [];
          if (authUser != null) {
            userBadges = List<String>.from(authUser.badges);
          } else if (profileState is ProfileLoaded) {
            userBadges = _parseUserBadges(profileState.user['badges']);
          }

          final unlockedCount =
              _allBadges.where((b) => userBadges.contains(b['requiredBadgeName'])).length;

          // XP calculation: 400 XP per badge
          final totalXp = unlockedCount * 400;
          final level = (totalXp / 1000).floor() + 1;
          final xpInLevel = totalXp % 1000;

          return ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              // ── XP Progress Hero ────────────────────────────────────────
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
                            Text(
                              'Level $level — ${authUser?.name ?? 'Fan'} Explorer',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$xpInLevel / 1000 XP to Level ${level + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        GlowingBadge(
                          label: 'Tier $level',
                          color: AppColors.comicYellow,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: xpInLevel / 1000,
                        minHeight: 10,
                        backgroundColor:
                            Colors.grey.withValues(alpha: 0.2),
                        color: AppColors.comicYellow,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Iconsax.cup,
                            size: 14, color: AppColors.comicYellow),
                        const SizedBox(width: 6),
                        Text(
                          '$unlockedCount / ${_allBadges.length} badges unlocked  •  $totalXp total XP',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white70
                                : AppColors.lightTextPrimary,
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
                  const Icon(Iconsax.medal_star,
                      size: 20, color: AppColors.comicRed),
                  const SizedBox(width: 8),
                  Text('All Trophies & Badges',
                      style: AppTextStyles.titleMedium
                          .copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 14),

              // ── Badge List ─────────────────────────────────────────────
              ..._allBadges.map((b) {
                final unlocked = userBadges
                    .contains(b['requiredBadgeName'] as String);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderColor: unlocked
                        ? AppColors.comicYellow.withValues(alpha: 0.5)
                        : null,
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: unlocked
                                ? AppColors.comicYellow
                                    .withValues(alpha: 0.15)
                                : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Icon(
                              b['icon'] as IconData,
                              size: 24,
                              color: unlocked
                                  ? AppColors.comicYellow
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      b['name'] as String,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: unlocked
                                            ? null
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: unlocked
                                          ? AppColors.comicYellow
                                              .withValues(alpha: 0.15)
                                          : Colors.grey
                                              .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      b['tier'] as String,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: unlocked
                                            ? AppColors.comicYellow
                                            : Colors.grey,
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
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    unlocked
                                        ? Iconsax.tick_circle
                                        : Iconsax.lock,
                                    size: 12,
                                    color: unlocked
                                        ? AppColors.success
                                        : AppColors.comicRed,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    unlocked ? 'Unlocked' : 'Locked',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: unlocked
                                          ? AppColors.success
                                          : AppColors.comicRed,
                                    ),
                                  ),
                                ],
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
          );
        },
      ),
    );
  }
}
