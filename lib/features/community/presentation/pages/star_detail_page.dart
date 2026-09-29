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

  bool _isValidUrl(String url) {
    final trimmed = url.trim();
    return trimmed.isNotEmpty &&
        (trimmed.startsWith('http://') || trimmed.startsWith('https://'));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final subtextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return BlocBuilder<CommunityBloc, CommunityState>(
      builder: (context, state) {
        // Keep star in sync with live bloc state
        StarProfile star = widget.star;
        if (state is CommunityLoaded) {
          final found = state.starProfiles.where((p) => p.id == widget.star.id);
          if (found.isNotEmpty) star = found.first;
        }

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Hero Sliver App Bar ──
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: isDark ? AppColors.darkSurface : AppColors.comicBlack,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.55),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                actions: [
                  // ── Bookmark toggle in appbar ──
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.55),
                      child: IconButton(
                        tooltip: star.isBookmarked ? 'Remove Bookmark' : 'Bookmark Profile',
                        icon: Icon(
                          star.isBookmarked ? Iconsax.bookmark : Iconsax.bookmark_2,
                          color: star.isBookmarked ? AppColors.comicYellow : Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          context.read<CommunityBloc>().add(ToggleStarBookmarkEvent(star.id));
                          if (mounted) {
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
                          }
                        },
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_isValidUrl(star.avatarUrl))
                        CachedNetworkImage(
                          imageUrl: star.avatarUrl.trim(),
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.darkSurface,
                            child: const Center(
                              child: CircularProgressIndicator(color: AppColors.comicRed),
                            ),
                          ),
                          errorWidget: (_, __, ___) => _buildFallbackHeader(star),
                        )
                      else
                        _buildFallbackHeader(star),

                      // Gradient overlay for contrast
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.4),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.85),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Profile Details ──
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
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    if (star.role.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.comicRed.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: AppColors.comicRed.withValues(alpha: 0.3)),
                                        ),
                                        child: Text(
                                          star.role.toUpperCase(),
                                          style: const TextStyle(
                                            color: AppColors.comicRed,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    if (star.category.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.comicYellowDark.withValues(alpha: 0.18),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          star.category.toUpperCase(),
                                          style: TextStyle(
                                            color: isDark ? AppColors.comicYellow : const Color(0xFFB45309),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  star.name,
                                  style: AppTextStyles.displaySmall.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                  ),
                                ),
                                if (star.socialHandle.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Iconsax.verify, size: 14, color: AppColors.comicRed),
                                      const SizedBox(width: 4),
                                      Text(
                                        star.socialHandle.startsWith('@')
                                            ? star.socialHandle
                                            : '@${star.socialHandle}',
                                        style: const TextStyle(
                                          color: AppColors.comicRed,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  'Known for: ${star.knownFor}',
                                  style: TextStyle(
                                    color: subtextColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Follow button with constrained size to prevent unconstrained layout crash
                          SizedBox(
                            width: 110,
                            child: SkewedButton(
                              text: _isFollowing ? 'Following' : 'Follow',
                              icon: _isFollowing ? Iconsax.tick_square : Iconsax.profile_add,
                              height: 42,
                              fontSize: 12,
                              backgroundColor: _isFollowing ? (isDark ? AppColors.darkSurface : AppColors.comicGray) : AppColors.comicRed,
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
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Stats Row
                      Row(
                        children: [
                          _buildStatBox('Fans', '${star.followersCount}', Iconsax.people, isDark),
                          const SizedBox(width: 10),
                          _buildStatBox('Credits', '48+ Titles', Iconsax.video_play, isDark),
                          const SizedBox(width: 10),
                          _buildStatBox('Rating', '9.8 / 10', Iconsax.star_1, isDark),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Biography
                      Text(
                        'Biography & Career',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        star.bio.isNotEmpty
                            ? star.bio
                            : 'No biography available for this star profile yet.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          height: 1.6,
                          color: subtextColor,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Notable Works
                      Text(
                        'Notable Iconic Roles',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._buildNotableRoles(isDark, star, textColor, subtextColor),
                      const SizedBox(height: 24),

                      // Convention Appearances
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        borderColor: AppColors.comicRed.withValues(alpha: 0.25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Iconsax.calendar_2, color: AppColors.comicRed),
                                const SizedBox(width: 8),
                                Text(
                                  'Upcoming Con Signings & Panels',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '• Anime Expo: Special Guest of Honor (Panel Room 408AB)\n'
                              '• Comic-Con International: Main Hall Autograph Session & VIP Meet',
                              style: TextStyle(fontSize: 13, height: 1.5, color: subtextColor),
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

  Widget _buildFallbackHeader(StarProfile star) {
    return Container(
      color: AppColors.comicBlack,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.profile_circle, size: 72, color: Colors.white30),
            const SizedBox(height: 8),
            Text(
              star.name,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, bool isDark) {
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.comicRed),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNotableRoles(
    bool isDark,
    StarProfile star,
    Color textColor,
    Color subtextColor,
  ) {
    if (star.famousWorks.isNotEmpty) {
      return star.famousWorks.map((work) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: GlassContainer(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        work,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: textColor),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        star.role,
                        style: TextStyle(fontSize: 11, color: subtextColor),
                      ),
                    ],
                  ),
                ),
                Text(
                  star.category,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.comicRed,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList();
    }

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r['title']!,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: textColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      r['role']!,
                      style: TextStyle(fontSize: 11, color: subtextColor),
                    ),
                  ],
                ),
              ),
              Text(
                r['year']!,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.comicRed,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
