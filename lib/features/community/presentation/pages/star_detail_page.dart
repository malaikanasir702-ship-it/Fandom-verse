import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/star_profile.dart';

class StarDetailPage extends StatefulWidget {
  final StarProfile star;

  const StarDetailPage({super.key, required this.star});

  @override
  State<StarDetailPage> createState() => _StarDetailPageState();
}

class _StarDetailPageState extends State<StarDetailPage> {
  bool _isFollowing = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.star.avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.darkSurface),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.darkSecondary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.star.role.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.darkSecondary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.star.name,
                              style: AppTextStyles.displaySmall.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Known for: ${widget.star.knownFor}',
                              style: TextStyle(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFollowing ? AppColors.darkSurface : AppColors.darkPrimary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _isFollowing = !_isFollowing;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_isFollowing
                                  ? '⭐ Joined ${widget.star.name}\'s Fan Club!'
                                  : 'Unfollowed ${widget.star.name}'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: Icon(_isFollowing ? Icons.check_rounded : Icons.person_add_rounded, size: 16),
                        label: Text(_isFollowing ? 'Following' : 'Follow'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Stats Row
                  Row(
                    children: [
                      _buildStatBox('Fans', '${widget.star.followersCount}', Icons.groups_rounded),
                      const SizedBox(width: 12),
                      _buildStatBox('Credits', '48+ Titles', Icons.movie_filter_rounded),
                      const SizedBox(width: 12),
                      _buildStatBox('Rating', '9.8 / 10', Icons.star_rounded),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Biography
                  Text('Biography & Career', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                    widget.star.bio,
                    style: AppTextStyles.bodyMedium.copyWith(
                      height: 1.6,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Notable Works
                  Text('Notable Iconic Roles', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  ..._buildNotableRoles(isDark),
                  const SizedBox(height: 24),

                  // Convention Appearances
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderColor: AppColors.darkSecondary.withValues(alpha: 0.3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.event_seat_rounded, color: AppColors.darkSecondary),
                            SizedBox(width: 8),
                            Text('Upcoming Con Signings & Panels', style: TextStyle(fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '• Anime Expo 2025: Special Guest of Honor (Panel Room 408AB)\n'
                          '• Comic-Con International: Main Hall Autograph Session & VIP Meet',
                          style: TextStyle(fontSize: 13, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon) {
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.darkSecondary),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNotableRoles(bool isDark) {
    final roles = [
      {'role': 'Protagonist Lead Voice', 'title': 'Attack on Titan / Jujutsu Kaisen', 'year': '2020-2024'},
      {'role': 'Iconic Anti-Hero', 'title': 'Fate/Zero / Fate: Heaven\'s Feel', 'year': '2015-2021'},
      {'role': 'Video Game Voice Lead', 'title': 'Genshin Impact / Honkai: Star Rail', 'year': '2023-Present'},
    ];

    return roles.map((r) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: GlassContainer(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r['title']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(r['role']!, style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                ],
              ),
              Text(r['year']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.darkSecondary)),
            ],
          ),
        ),
      );
    }).toList();
  }
}
