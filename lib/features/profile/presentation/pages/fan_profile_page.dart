import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glowing_badge.dart';

class FanProfilePage extends StatelessWidget {
  const FanProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fan Profile', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Avatar & Name Card
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.darkPrimary, AppColors.darkSecondary],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.darkPrimary.withValues(alpha: 0.4),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.person_rounded, size: 54, color: Colors.white),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed('/edit-profile'),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.darkSecondary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit_rounded, size: 16, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Alex Rivera',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@OtakuMaster_99 • Member since 2024',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const GlowingBadge(
                    label: '🏆 Lore Master Tier III',
                    color: AppColors.darkAccentGold,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Profile Stats
            Row(
              children: [
                _buildStatItem('Discussions', '38', isDark),
                const SizedBox(width: 12),
                _buildStatItem('RSVP Events', '5', isDark),
                const SizedBox(width: 12),
                _buildStatItem('Badges', '14', isDark),
              ],
            ),
            const SizedBox(height: 24),

            // Bio / Fandom Statement
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fandom Bio',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Die-hard Shonen anime fan, Soulsborne speedrun enthusiast, and Marvel comics archivist. Always looking for new convention meetups!',
                    style: AppTextStyles.bodySmall.copyWith(
                      height: 1.5,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Subscribed Fandoms
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Selected Fandoms',
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed('/interest-setup'),
                  child: const Text('Manage', style: TextStyle(color: AppColors.darkSecondary)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                '⚔️ Demon Slayer',
                '🎮 Elden Ring',
                '⚡ Marvel Multiverse',
                '🎶 BTS ARMY',
                '🌌 Star Wars Lore',
              ].map((f) => Chip(
                    label: Text(f, style: const TextStyle(fontSize: 12)),
                    backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  )).toList(),
            ),
            const SizedBox(height: 24),

            // Quick Nav Links
            _buildProfileNavTile(
              context,
              icon: Icons.military_tech_rounded,
              title: 'Achievements & Badges',
              subtitle: '14 Unlocked • 3 In Progress',
              route: '/badges',
              color: AppColors.darkAccentGold,
            ),
            _buildProfileNavTile(
              context,
              icon: Icons.notifications_outlined,
              title: 'Notifications & Alerts',
              subtitle: 'Upcoming con reminders & replies',
              route: '/notifications',
              color: AppColors.darkSecondary,
            ),
            _buildProfileNavTile(
              context,
              icon: Icons.bookmark_border_rounded,
              title: 'Bookmarks & Favorites',
              subtitle: 'Saved lore articles, terms & events',
              route: '/bookmarks',
              color: AppColors.darkPrimary,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String count, bool isDark) {
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(
              count,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileNavTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassContainer(
        onTap: () => Navigator.of(context).pushNamed(route),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: isDark ? Colors.white38 : Colors.black38),
          ],
        ),
      ),
    );
  }
}
