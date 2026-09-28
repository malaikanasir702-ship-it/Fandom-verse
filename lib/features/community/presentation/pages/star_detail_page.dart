import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../../domain/entities/star_profile.dart';
import '../bloc/community_bloc.dart';
import '../bloc/community_event.dart';
import '../bloc/community_state.dart';

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

    return BlocBuilder<CommunityBloc, CommunityState>(
      builder: (context, state) {
        // Keep star in sync with live bloc state
        StarProfile star = widget.star;
        if (state is CommunityLoaded) {
          final found = state.starProfiles.where((p) => p.id == widget.star.id);
          if (found.isNotEmpty) star = found.first;
        }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              // ── Bookmark toggle in appbar ──
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.45),
                  child: IconButton(
                    tooltip: star.isBookmarked ? 'Remove Bookmark' : 'Bookmark Profile',
                    icon: Icon(
                      star.isBookmarked ? Iconsax.bookmark : Iconsax.bookmark_2,
                      color: star.isBookmarked ? AppColors.comicYellow : Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      context.read<CommunityBloc>().add(ToggleStarBookmarkEvent(star.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            star.isBookmarked
                                ? 'Removed ${star.name} from bookmarks.'
                                : '⭐ ${star.name} bookmarked! Available offline.',
                          ),
                          backgroundColor: star.isBookmarked
                              ? AppColors.comicBlack
                              : AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: star.avatarUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: AppColors.darkSurface,
                      child: const Center(
                        child: CircularProgressIndicator(color: AppColors.comicRed),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.darkSurface,
                      child: const Icon(Iconsax.profile_circle, size: 64, color: Colors.white30),
                    ),
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
                                star.role.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.darkSecondary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              star.name,
                              style: AppTextStyles.displaySmall.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Known for: ${star.knownFor}',
                              style: TextStyle(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SkewedButton(
                        text: _isFollowing ? 'Following' : 'Follow',
                        icon: _isFollowing ? Iconsax.tick_square : Iconsax.profile_add,
                        height: 44,
                        fontSize: 12,
                        backgroundColor: _isFollowing ? AppColors.darkSurface : AppColors.darkPrimary,
                        onPressed: () {
                          setState(() {
                            _isFollowing = !_isFollowing;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_isFollowing
                                  ? '⭐ Joined ${star.name}\'s Fan Club!'
                                  : 'Unfollowed ${star.name}'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Stats Row
                  Row(
                    children: [
                      _buildStatBox('Fans', '${star.followersCount}', Iconsax.people),
                      const SizedBox(width: 12),
                      _buildStatBox('Credits', '48+ Titles', Iconsax.video_play),
                      const SizedBox(width: 12),
                      _buildStatBox('Rating', '9.8 / 10', Iconsax.star_1),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Biography
                  Text('Biography & Career', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                    star.bio,
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
                            Icon(Iconsax.calendar_2, color: AppColors.darkSecondary),
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
      },
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


